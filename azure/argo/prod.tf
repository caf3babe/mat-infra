locals {
  project_name = "mat-project-2110838008"
  cluster_name = "argo"
}

resource "azurerm_resource_group" "rg_argo" {
  name     = join("-", [local.project_name, local.cluster_name])
  location = "West Europe"
}

resource "azurerm_network_watcher" "nw_watcher_argo" {
  name                = join("-", [local.project_name, "nwwatcher"])
  location            = azurerm_resource_group.rg_argo.location
  resource_group_name = azurerm_resource_group.rg_argo.name
}

resource "azurerm_kubernetes_cluster" "aks_argo" {
  name                = "aks-argo"
  location            = azurerm_resource_group.rg_argo.location
  resource_group_name = azurerm_resource_group.rg_argo.name
  dns_prefix          = join("-", [local.project_name, local.cluster_name])
  node_resource_group = join("-", [azurerm_resource_group.rg_argo.name, "aks-managed"])

  default_node_pool {
    name       = "default"
    node_count = 4
    vm_size    = "Standard_D11_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

resource "local_sensitive_file" "client_certificate" {
  content     = azurerm_kubernetes_cluster.aks_argo.kube_config.0.client_certificate
  filename = "${path.module}/../${local.project_name}-${local.cluster_name}-kube_client.crt"
}

resource "local_sensitive_file" "kube_config" {
  content     = azurerm_kubernetes_cluster.aks_argo.kube_config_raw
  filename = "${path.module}/../${local.project_name}-${local.cluster_name}-kube.conf"
}
