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

# Spinnaker

Spin up kubernetes cluster in azure
terraform -chdir=azure/spinnaker apply -auto-approve

1. Controller -> HAL; this is needed to install and update spinnaker 

~~~~bash
docker pull us-docker.pkg.dev/spinnaker-community/docker/halyard:stable
 
docker run -p 8084:8084 -p 9000:9000 \
--name halyard --rm \
-v "$(pwd)/azure/spinnaker/hal-config":"/home/spinnaker/.hal" \
-v "$(pwd)/azure/mat-project-2110838008-spinnaker-tooling-kube.conf":"/home/spinnaker/.kube/config" \
-it \
us-docker.pkg.dev/spinnaker-community/docker/halyard:stable

docker exec -it halyard bash
~~~~

2. Setup azure as provider for distributed instalaltion and azure storage as spinnaker storage

~~~~bash

# === provider account
az account show
SUBSCRIPTION_ID=300902f9-e92f-4317-b37b-4d6bc8c0b13c

az ad sp create-for-rbac --name "Spinnaker" --role contributor --scopes /subscriptions/${SUBSCRIPTION_ID}
APP_ID=b8d2b544-2889-44e9-b249-501fcc997245
APP_KEY=0n~8Q~xpzXa-u9PsNnClrUlR33_Zr6aCjMc5uaRz
TENANT_ID=15327e95-e6c8-4281-ba48-0e764fc6b973

RESOURCE_GROUP="Spinnaker"
az group create --name "${RESOURCE_GROUP}" --location westeurope

VAULT_NAME="mat-project"
az keyvault create --enabled-for-template-deployment true --resource-group "${RESOURCE_GROUP}" --name "${VAULT_NAME}"

hal config provider azure account add my-azure-account --client-id "${APP_ID}" --tenant-id "${TENANT_ID}" --subscription-id "${SUBSCRIPTION_ID}" --default-key-vault "${VAULT_NAME}" --default-resource-group "${RESOURCE_GROUP}" --packer-resource-group "${RESOURCE_GROUP}" --app-key "${APP_KEY}"

# === storage
STORAGE_ACCOUNT_NAME="matproject"
az storage account create --resource-group $RESOURCE_GROUP --sku STANDARD_LRS --name $STORAGE_ACCOUNT_NAME
# execute following to get the account key
# STORAGE_ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" | tr -d '"')

STORAGE_ACCOUNT_KEY="9KNKuyvBtkqLnKKQ+rFKJJ8QPJDqAuoNn/mH9Pv2hfgxdmXvEqETPXZALVw0O1IfHqqk9ZjsPkOR+AStG5/MUA=="
hal config storage azs edit --storage-account-name "${STORAGE_ACCOUNT_NAME}" --storage-account-key "${STORAGE_ACCOUNT_KEY}"
hal config storage edit --type azs

~~~~

3. Kubernetes cluster for tooling and deployment Spinnaker  
Defined in Terraform.  
Kubeconfig added as volume to halyard container.  
~~~~bash
terraform apply -auto-approve

hal config provider kubernetes account add my-k8s-account --context aks-spinnaker-tooling

VERSION=1.29.2
hal config version edit --version $VERSION
hal deploy apply

~~~~

5. Port forward to use Spinnakers web UI
~~~~bash
kubectl port-forward -n spinnaker svc/spin-deck 9000:9000 &
kubectl port-forward -n spinnaker svc/spin-gate 8084:8084 &

~~~~

6. Backup/restore halyard config
~~~~bash
# === backup config
hal backup create
cp /home/spinnaker/halyard-2023-03-05_18-09-14-181Z.tar /home/spinnaker/.hal/

# === restore config
hal backup restore --backup-path /home/spinnaker/.hal/halyard-2023-03-05_18-09-14-181Z.tar

~~~~