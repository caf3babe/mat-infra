# Terraform configuration for Master Thesis Project

## Local infrastructure

For local setup Vagrant is used. Vagrant comes with a concept of boxes, which essentially are images of ready made virtual machines. Various images can be downloaded from https://app.vagrantup.com/boxes/search[Vagrant Cloud]. The defintion of infrastructure is done in a file called "Vagrantfile". Following commands can be used to initiate the creation of local infrastructure. 

Prerequisites: 
* Virtual Box
* Vagrant, incl. vagrant-disksize plugin

```bash
brew install vagrant
brew install ngrok/ngrok/ngrok
vagrant plugin install vagrant-share
vagrant plugin install vagrant-disksize
vagrant init phoenixmedia/k3s
vagrant up 

# copy the kubeconfig file from the vm to be able to connect from outside

# install operator lifecycle manager
```

### Halyard Spinnaker

https://spinnaker.io/docs/setup/install/faq/
```bash
# all hal commands https://spinnaker.io/docs/reference/halyard/commands/
# apply configuraiton change with
hal deploy apply


```

### Flagger

Prereq. setup FluxCD

brew install fluxcd/tap/flux
export GITHUB_TOKEN=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
export GITHUB_USER=caf3babe


## Cloud infrastructure

### Flagger
```bash
terraform -chdir=azure/flagger apply -auto-approve

# start, stop aks cluster
az aks stop --name aks-prod -g mat-project-2110838008-prod
az aks start --name aks-prod -g mat-project-2110838008-prod

terraform -chdir=azure/flagger apply -replace=azurerm_kubernetes_cluster.aks_flagger -auto-approve
```

### Argo Rolouts
```bash
terraform -chdir=azure/flagger apply -auto-approve

# start, stop aks cluster
az aks stop --name aks-prod -g mat-project-2110838008-prod
az aks start --name aks-prod -g mat-project-2110838008-prod

terraform -chdir=azure/flagger apply -replace=azurerm_kubernetes_cluster.aks_flagger -auto-approve
```

### Spinnaker

#### Spin up kubernetes cluster in azure
```bash
./init-spinnaker.sh

# from mat-deploy repo execute deploy-services as instructed in the REAMDE.md of that repo
```

#### Destroy Spinnaker cluster including config

```bash
terraform -chdir=azure/spinnaker destroy -auto-approve
docker stop halyard
rm -r azure/spinnaker/hal-config
rm azure/spinnaker-secrets.yaml
```

#### Port forward to use Spinnakers web UI
```bash
kubectl port-forward svc/spin-deck 9000:9000 > /dev/null &
kubectl port-forward svc/spin-gate 8084:8084 > /dev/null &

kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 8080:80 > /dev/null &
```

#### Backup/restore halyard config
```bash
# === backup config
hal backup create
cp /home/spinnaker/halyard-2023-03-05_18-09-14-181Z.tar /home/spinnaker/.hal/

# === restore config
hal backup restore --backup-path /home/spinnaker/.hal/halyard-2023-03-05_18-09-14-181Z.tar
```
