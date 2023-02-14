#!/bin/bash
gatus_url="https://dev-gatus.rpgp.cc/"
output_filename=./cm_gatus.yaml
file=./services.csv
tgs_env=dev
telegram_token=$(kubectl get secrets tgs-gatus --output="jsonpath={.data.telegram-token}" -n $tgs_env | base64 --decode)
telegram_channel_id=$(kubectl get secrets tgs-gatus --output="jsonpath={.data.telegram-channel-id}" -n $tgs_env | base64 --decode)
storage_type=$(kubectl get secrets tgs-gatus --output="jsonpath={.data.storage-type}" -n $tgs_env | base64 --decode)
storage_path=$(kubectl get secrets tgs-gatus --output="jsonpath={.data.storage-path}" -n $tgs_env | base64 --decode)
cat << EOF > ./cm_gatus.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  annotations:
    meta.helm.sh/release-name: gatus
    meta.helm.sh/release-namespace: $tgs_env
  labels:
    app.kubernetes.io/instance: gatus
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: gatus
    app.kubernetes.io/version: v5.2.0
    helm.sh/chart: gatus-3.1.3
  name: gatus
  namespace: $tgs_env
data:
  config.yaml: |-
    alerting:
      telegram:
        token: "$telegram_token"
        id: "$telegram_channel_id"
    storage:
      type: $storage_type
      path: $storage_path
    endpoints:
EOF
while read -r line; do
    echo -e "$line"
    IFS=',' read -r -a arrIn <<< "$line";unset EOF;
    echo ${arrIn[4]}

    cat << EOF >> $output_filename
      - group: ${arrIn[0]}
        name: ${arrIn[1]}
        url: ${arrIn[3]}
        interval: ${arrIn[2]}
        conditions:
          - ${arrIn[4]}
        alerts:
        - type: telegram
          enabled: true
          description: "healthcheck failed\nplease check ${gatus_url}"
          send-on-resolved: true
EOF
    echo "========================="
done <$file