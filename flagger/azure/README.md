# spin up aks clusters

```bash
terraform apply 
terraform output -raw kube_config > prod_kube.config
```

# start, stop aks cluster
az aks stop --name aks-prod -g mat-project-2110838008-prod
az aks start --name aks-prod -g mat-project-2110838008-prod
```