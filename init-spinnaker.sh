#!/usr/bin/env bash

## This way of installing spinnaker leads to an issue where the kayenta config is kind of not functional and you cannot safe canary pipelines
## instead another option will be used: https://github.com/OpsMx/spinnaker-helm

set -euo pipefail

if [[ -f /Applications/Docker.app ]]; then
  open /Applications/Docker.app
fi

 

terraform -chdir=azure/spinnaker output -json | yq -P > azure/spinnaker-secrets.yaml

docker pull us-docker.pkg.dev/spinnaker-community/docker/halyard:stable
 
docker run -p 8084:8084 -p 9000:9000 --name halyard --rm -d \
-v "$(pwd)/azure/spinnaker/hal-config":"/home/spinnaker/.hal" \
-v "$(pwd)/azure/mat-project-2110838008-spinnaker-kube.conf":"/home/spinnaker/.kube/config" \
-v "$(pwd)/azure/spinnaker-secrets.yaml":"/home/spinnaker/spinnaker-secrets.yaml" \
us-docker.pkg.dev/spinnaker-community/docker/halyard:stable || true
# wait for container to boot
sleep 60

docker exec -i -u root halyard /bin/bash <<'EOF'

apk update
apk add jq

wget -q -O /usr/bin/yq $(wget -q -O - https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r '.assets[] | select(.name == "yq_linux_amd64") | .browser_download_url')
chmod +x /usr/bin/yq
EOF

docker exec -i halyard /bin/bash <<'EOF'

set -euo pipefail

SUBSCRIPTION_ID=$(yq -r '.subscription_id.value' /home/spinnaker/spinnaker-secrets.yaml)
TENANT_ID=$(yq -r '.tenant_id.value' /home/spinnaker/spinnaker-secrets.yaml)
APP_ID=$(yq -r '.app_id.value' /home/spinnaker/spinnaker-secrets.yaml)
APP_KEY=$(yq -r '.app_key.value' /home/spinnaker/spinnaker-secrets.yaml)
RESOURCE_GROUP=$(yq -r '.resource_group.value' /home/spinnaker/spinnaker-secrets.yaml)
VAULT_NAME=$(yq -r '.vault_name.value' /home/spinnaker/spinnaker-secrets.yaml)
STORAGE_ACCOUNT_NAME=$(yq -r '.storage_account_name.value' /home/spinnaker/spinnaker-secrets.yaml)
STORAGE_ACCOUNT_KEY=$(yq -r '.storage_account_key.value' /home/spinnaker/spinnaker-secrets.yaml)

# 1.29.3, 1.28.5, 1.27.4
hal config version edit --version "1.28.5"

hal config provider azure enable
hal config provider azure account add my-azure-account --client-id "${APP_ID}" --tenant-id "${TENANT_ID}" --subscription-id "${SUBSCRIPTION_ID}" --default-key-vault "${VAULT_NAME}" --default-resource-group "${RESOURCE_GROUP}" --packer-resource-group "${RESOURCE_GROUP}" --app-key "${APP_KEY}"

hal config provider kubernetes enable
hal config provider kubernetes account add my-k8s-account --context aks-spinnaker

hal config storage azs edit --storage-account-name "${STORAGE_ACCOUNT_NAME}" --storage-account-key "${STORAGE_ACCOUNT_KEY}"
hal config storage edit --type azs

hal config deploy edit --type distributed --account-name my-k8s-account

hal config canary enable
hal config canary prometheus enable
hal config canary prometheus account add my-prometheus-account --base-url "http://kube-prometheus-stack-prometheus.monitoring:9090"
hal config canary edit --default-metrics-store prometheus
hal config canary edit --default-metrics-account my-prometheus-account
hal config canary edit --default-storage-account "${STORAGE_ACCOUNT_NAME}"

hal deploy apply

EOF
