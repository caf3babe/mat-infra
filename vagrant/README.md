# Local infrastructure

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

## Halyard Spinnaker

https://spinnaker.io/docs/setup/install/faq/
```bash
# all hal commands https://spinnaker.io/docs/reference/halyard/commands/
# apply configuraiton change with
hal deploy apply


```

## Flagger

Prereq. setup FluxCD

brew install fluxcd/tap/flux
export GITHUB_TOKEN=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
export GITHUB_USER=caf3babe
