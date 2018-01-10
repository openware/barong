{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expands image name.
*/}}
{{- define "image" -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Environment for database migration job.
It is pre-install hook, so we don't have secrets created yet and we need to use plain password.
*/}}
{{- define "prepare-db-env" -}}
- name: RAILS_ENV
  value: production
- name: DATABASE_HOST
  value: {{ .Values.db.host }}
- name: DATABASE_USER
  value: {{ default "root" .Values.db.user }}
- name: DATABASE_NAME
  value: {{ default "barong_production" .Values.db.name }}
{{- if .Values.db.password }}
- name: DATABASE_PASSWORD
  value: {{ .Values.db.password }}
{{- end }}
- name: SECRET_KEY_BASE
  value: ""
{{- end -}}

{{/*
Environment for barong container
*/}}
{{- define "env" -}}
{{- range $key, $value := .Values.barong.env }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
- name: RAILS_ENV
  value: production
- name: URL_HOST
  value: {{ .Values.ingress.host }}
- name: URL_SCHEME
  value: http{{ if .Values.ingress.tls }}s{{ end }}
- name: DATABASE_HOST
  value: {{ .Values.db.host }}
- name: DATABASE_USER
  value: {{ default "root" .Values.db.user }}
- name: DATABASE_NAME
  value: {{ default "barong_production" .Values.db.name }}
{{- if .Values.db.password }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "fullname" . }}
      key: dbPassword
{{- end }}
- name: SECRET_KEY_BASE
  valueFrom:
    secretKeyRef:
      name: {{ template "fullname" . }}
      key: cookiesSecretKey
{{- end -}}
