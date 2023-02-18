# Terraform configuration for mat project

# Azure Terraform

```bash
terraform apply 
terraform output -raw kube_config > prod_kube.config
```

# start, stop aks cluster
az aks stop --name aks-prod -g mat-project-2110838008-prod
az aks start --name aks-prod -g mat-project-2110838008-prod
```
terraform -chdir=azure/flagger apply -replace=azurerm_kubernetes_cluster.aks_flagger -auto-approve