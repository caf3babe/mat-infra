# Terraform configuration for mat project

# Azure Terraform

## Flagger
```bash
terraform -chdir=azure/flagger apply -auto-approve

# start, stop aks cluster
az aks stop --name aks-prod -g mat-project-2110838008-prod
az aks start --name aks-prod -g mat-project-2110838008-prod

terraform -chdir=azure/flagger apply -replace=azurerm_kubernetes_cluster.aks_flagger -auto-approve
```

## Argo Rolouts
```bash
terraform -chdir=azure/flagger apply -auto-approve

# start, stop aks cluster
az aks stop --name aks-prod -g mat-project-2110838008-prod
az aks start --name aks-prod -g mat-project-2110838008-prod

terraform -chdir=azure/flagger apply -replace=azurerm_kubernetes_cluster.aks_flagger -auto-approve
```

## Spinnaker

### Spin up kubernetes cluster in azure
```bash
./init-spinnaker.sh

# from mat-deploy repo execute following script
./deploy-services spinnaker
```

### Destroy Spinnaker cluster including config

```bash
terraform -chdir=azure/spinnaker destroy -auto-approve
docker stop halyard
rm -r azure/spinnaker/hal-config
rm azure/spinnaker-secrets.yaml
```

### Port forward to use Spinnakers web UI
```bash
kubectl port-forward -n spinnaker svc/spin-deck 9000:9000 > /dev/null &
kubectl port-forward -n spinnaker svc/spin-gate 8084:8084 > /dev/null &
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 8080:80 > /dev/null &
```

### Backup/restore halyard config
```bash
# === backup config
hal backup create
cp /home/spinnaker/halyard-2023-03-05_18-09-14-181Z.tar /home/spinnaker/.hal/

# === restore config
hal backup restore --backup-path /home/spinnaker/.hal/halyard-2023-03-05_18-09-14-181Z.tar
```