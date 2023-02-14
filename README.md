# dev 
### 新增 helm repo 
helm repo add gatus https://avakarev.github.io/gatus-chart
helm repo update

### 服務檔案
kubectl get svc -n dev | awk '{print $1}' > service.txt
services: https://docs.google.com/spreadsheets/d/1aKM0LlNc96vuZZeqQdKlBLveBm0I0h-zsklvqhurjzM/edit#gid=1439647638
download to services.csv
執行 bash dev/convert_to_config.sh dev services-dev.csv http://dev-gatus.rpgp.cc/ 來產生 config.yaml


bash dev/convert_to_config.sh 來產生  config.yaml



### 執行安裝
helm template gatus ./dev/ --set-file config=dev/config.yaml --set ingress.enabled=true --set ingress.hosts[0]=dev-gatus.rpgp.cc -f dev/values.yaml -n dev | kubectl apply -f -

helm install gatus ./dev/ --set-file config=dev/config.yaml --set ingress.enabled=true --set ingress.hosts[0]=dev-gatus.rpgp.cc -f dev/values.yaml -n dev

helm uninstall gatus -n dev


### 更新 configmap
bash dev/convert_to_configmap.sh & 

kubectl apply -f dev/cm_gatus.yaml & 
kubectl rollout restart deploy gatus -n dev 

kubectl get pods -n dev | grep gatus
check on https://dev-gatus.rpgp.cc/

REF: https://github.com/TwiN/gatus#monitoring-a-tcp-endpoint