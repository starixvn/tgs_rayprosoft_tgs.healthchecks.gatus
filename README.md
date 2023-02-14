# dev 
### 新增 helm repo 
helm repo add gatus https://avakarev.github.io/gatus-chart
helm repo update

### 服務檔案
kubectl get svc -n dev | awk '{print $1}' > service.txt
services: https://docs.google.com/spreadsheets/d/1aKM0LlNc96vuZZeqQdKlBLveBm0I0h-zsklvqhurjzM/edit#gid=1439647638
download to services.csv
執行 

bash dev/convert_to_config.sh 來產生  config.yaml


### 執行安裝
helm template gatus . --set-file config=config-dev.yaml --set ingress.enabled=true --set ingress.hosts[0]=dev-gatus.rpgp.cc -f values.yaml -n dev | kubectl apply -f -

# dev
bash convert_to_config.sh dev services-dev.csv https://dev-gatus.rpgp.cc/ 
helm template gatus . --set-file config=config-dev.yaml --set ingress.enabled=true --set ingress.hosts[0]=stg-gatus.rpgp.cc -f values.yaml -n dev | kubectl apply -f -

# staging
bash convert_to_config.sh staging services-staging.csv https://stg-gatus.rpgp.cc/ 
helm template gatus . --set-file config=config-staging.yaml --set ingress.enabled=true --set ingress.hosts[0]=stg-gatus.rpgp.cc -f values.yaml -n staging | kubectl apply -f -


# prod 
bash convert_to_config.sh prod services-prod.csv https://healthcheck.srvptt.com/ 
helm template gatus . --set-file config=config-prod.yaml --set ingress.enabled=true --set ingress.hosts[0]=healthcheck.srvptt.com -f values.yaml -n prod | kubectl apply -f -


REF: https://github.com/TwiN/gatus#monitoring-a-tcp-endpoint
