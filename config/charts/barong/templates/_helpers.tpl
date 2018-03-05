{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "barong.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expands image name.
*/}}
{{- define "barong.image" -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "barong.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Environment for database migration job.
It is pre-install hook, so we don't have secrets created yet and we need to use plain password.
*/}}
{{- define "barong.hook-env" -}}
- name: RAILS_ENV
  value: "production"
- name: RAILS_LOG_TO_STDOUT
  value: "true"
- name: DATABASE_HOST
  value: {{ .Values.db.host | quote }}
- name: DATABASE_USER
  value: {{ default "root" .Values.db.user | quote }}
- name: DATABASE_NAME
  value: {{ default "barong_production" .Values.db.name | quote }}
{{- if .Values.db.password }}
- name: DATABASE_PASSWORD
  value: {{ .Values.db.password | quote }}
{{- end }}
- name: SECRET_KEY_BASE
  value: {{ default "changeme" .Values.secretKeyBase | quote }}
- name: DEVISE_SECRET_KEY
  value: {{ default "changeme" .Values.deviseSecretKey | quote }}
- name: STORAGE_PROVIDER
  value: {{ required "storage.provider is required!" .Values.storage.provider | quote }}
- name: STORAGE_BUCKET_NAME
  value: {{ required "storage.bucket is required!" .Values.storage.bucket | quote }}
{{ if eq .Values.storage.provider "AWS" }}
- name: STORAGE_REGION
  value: {{ required "storage.region is required!" .Values.storage.region | quote }}
{{ end }}
- name: JWT_SHARED_SECRET_KEY
  value: {{ .Values.jwtSharedSecretKey }}
{{- end -}}

{{/*
Environment for barong container
*/}}
{{- define "barong.env" -}}
- name: PORT
  value: {{ .Values.service.internalPort | quote }}
- name: RAILS_ENV
  value: {{ default "production" .Values.app.env }}
- name: RAILS_LOG_TO_STDOUT
  value: "true"
- name: URL_HOST
  value: {{ .Values.ingress.hosts | first }}
- name: URL_SCHEME
  value: http{{ if .Values.ingress.tls }}s{{ end }}
- name: DATABASE_HOST
  value: {{ .Values.db.host }}
- name: DATABASE_USER
  value: {{ default "root" .Values.db.user }}
- name: DATABASE_NAME
  value: {{ default "barong_production" .Values.db.name }}
- name: SMTP_ADDRESS
  value: {{ default "smtp-relay.kube-services" .Values.smtp.address }}
- name: SMTP_PORT
  value: {{ default "25" .Values.smtp.port | quote }}
- name: SMTP_DOMAIN
  value: {{ default "helioscloud.com" .Values.smtp.domain }}
- name: STORAGE_BUCKET_NAME
  value: {{ required "storage.bucket is required!" .Values.storage.bucket }}
{{- if .Values.vault.enabled }}
- name: VAULT_ADDR
  value: {{ .Values.vault.adress }}
{{- end }}
{{- range $key, $value := .Values.app.vars }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "barong.fullname" . }}
      key: dbPassword
- name: SECRET_KEY_BASE
  valueFrom:
      secretKeyRef:
        name: {{ template "barong.fullname" . }}
        key: secretKeyBase
- name: DEVISE_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ template "barong.fullname" . }}
      key: deviseSecretKey
- name: TWILIO_ACCOUNT_SID
  valueFrom:
    secretKeyRef:
      name: {{ template "barong.fullname" . }}
      key: twilioAccountSid
- name: TWILIO_AUTH_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ template "barong.fullname" . }}
      key: twilioAuthToken
- name: TWILIO_PHONE_NUMBER
  valueFrom:
    secretKeyRef:
      name: {{ template "barong.fullname" . }}
      key: twilioPhoneNumber
- name: STORAGE_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ template "barong.fullname" . }}
      key: storageAccessKey
- name: STORAGE_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ template "barong.fullname" . }}
      key: storageSecretKey
{{- if .Values.vault.enabled }}
- name: VAULT_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ template "barong.fullname" . }}
      key: vaultToken
{{- end }}
{{- if .Values.jwtSharedSecretKey }}
- name: JWT_SHARED_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ template "barong.fullname" . }}
      key: jwtSharedSecretKey
{{- end }}
{{- end -}}

{{/*
labels.standard prints the standard Helm labels.
The standard labels are frequently used in metadata.
*/}}
{{- define "barong.labels.standard" -}}
app: {{ template "barong.name" . }}
heritage: {{ .Release.Service | quote }}
release: {{ .Release.Name | quote }}
chart: {{ template "barong.chartref" . }}
{{- end -}}

{{/*
chartref prints a chart name and version.
It does minimal escaping for use in Kubernetes labels.
*/}}
{{- define "barong.chartref" -}}
  {{- replace "+" "_" .Chart.Version | printf "%s-%s" .Chart.Name -}}
{{- end -}}

{{/*
Templates in barong.utils namespace are help functions.
*/}}

{{/*
barong.utils.tls functions makes host-tls from host name
usage: {{ "www.example.com" | barong.utils.tls }}
output: www-example-com-tls
*/}}
{{- define "barong.utils.tls" -}}
{{- $host := index . | replace "." "-" -}}
{{- printf "%s-tls" $host -}}
{{- end -}}
