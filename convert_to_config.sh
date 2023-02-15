#!/bin/bash
tgs_env=$1
file=services/$2
gatus_url=$3
output_filename=config-$tgs_env.yaml
telegram_token=$(kubectl get secrets tgs-gatus --output="jsonpath={.data.telegram-token}" -n $tgs_env | base64 --decode)
telegram_channel_id=$(kubectl get secrets tgs-gatus --output="jsonpath={.data.telegram-channel-id}" -n $tgs_env | base64 --decode)
storage_type=$(kubectl get secrets tgs-gatus --output="jsonpath={.data.storage-type}" -n $tgs_env | base64 --decode)
storage_path=$(kubectl get secrets tgs-gatus --output="jsonpath={.data.storage-path}" -n $tgs_env | base64 --decode)
cat << EOF > $output_filename
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