# Flagger

We can use flagger with or without flux. As ingress controller and traffic management istio will be used. Following steps need to be done for flagger using flux:

```bash
export GITHUB_TOKEN=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

flux bootstrap github \
  --owner=caf3babe \
  --repository=mat-clusters \
  --path=clusters/flagger \
  --personal

istioctl install -set values.global.proxy.resources.requests.cpu=10m -set values.global.proxy.resources.requests.memory=40Mi

kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.16/samples/addons/prometheus.yaml


# echo -n "caf3babe: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" | base64
# echo -n '{"auths":{"ghcr.io":{"auth":"Y2FmM2JhYmU6Z2hwX2ZXdDBPRVZqbXhDS2ZhUk1QNW1BOE1OZFdYWWNEMzJuREJqRg=="}}}' | base64

kubectl apply -n apps -f << EOL
kind: Secret
type: kubernetes.io/dockerconfigjson
apiVersion: v1
metadata:
  name: dockerconfigjson-github-com
  labels:
    app: app-name
data:
  .dockerconfigjson: eyJhdXRocyI6eyJnaGNyLmlvIjp7ImF1dGgiOiJZMkZtTTJKaFltVTZaMmh3WDJaWGREQlBSVlpxYlhoRFMyWmhVazFRTlcxQk9FMU9aRmRZV1dORU16SnVSRUpxUmc9PSJ9fX0=
EOL


# Azure Terraform

```bash
terraform apply 
terraform output -raw kube_config > prod_kube.config
```

# start, stop aks cluster
az aks stop --name aks-prod -g mat-project-2110838008-prod
az aks start --name aks-prod -g mat-project-2110838008-prod
```
