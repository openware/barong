#!/bin/sh

set -ex

helm_barong_lines=$(helm list barong | wc -l)
case ${helm_barong_lines} in
  0) action=install ;;
  2) action=upgrade ;;
  *) echo "[FATAL]: helm list reported ${helm_barong_lines} lines"; false ;;
esac

ns="kube-services"

db="gcloud-sqlproxy-gcloud-sqlproxy"

k8s_gcloud_sql_lines=$(kubectl get svc -n $ns $db | wc -l)
if [ ${k8s_gcloud_sql_lines} -ne "2" ]; then
  echo "First install gcloud-sqlproxy into \"$ns\" namespace"; false
fi

db_pass=$(cat ~/safe/`kubectl config current-context`_barong_db_pass)
echo "Current context database password is \"$db_pass\""

params=(
  --set db.host="$db.$ns"
  --set db.password="$db_pass"
  config/charts/barong
)

case "${action}" in
  install)
    echo "[INFO] Installing Barong"
    helm install --name barong ${params[@]}
    ;;

  upgrade)
    echo "[INFO] Upgrading Barong"
    helm upgrade barong ${params[@]}
    ;;

  *)
    echo "Fatal issue: Unknown action ${action}"
    false
    ;;
esac
