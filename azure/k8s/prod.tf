locals {
  project_name = "mat-project-2110838008"
  cluster_name = "k8s"
}

resource "azurerm_resource_group" "rg_k8s" {
  name     = join("-", [local.project_name, local.cluster_name])
  location = "West Europe"
}

resource "azurerm_network_watcher" "nw_watcher_k8s" {
  name                = join("-", [local.project_name, "nwwatcher"])
  location            = azurerm_resource_group.rg_k8s.location
  resource_group_name = azurerm_resource_group.rg_k8s.name
}

resource "azurerm_kubernetes_cluster" "aks_k8s" {
  name                = "aks-k8s"
  location            = azurerm_resource_group.rg_k8s.location
  resource_group_name = azurerm_resource_group.rg_k8s.name
  dns_prefix          = join("-", [local.project_name, local.cluster_name])
  node_resource_group = join("-", [azurerm_resource_group.rg_k8s.name, "aks-managed"])

  default_node_pool {
    name       = "default"
    node_count = 3
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
  content     = azurerm_kubernetes_cluster.aks_k8s.kube_config.0.client_certificate
  filename = "${path.module}/../${local.project_name}-${local.cluster_name}-kube_client.crt"
}

resource "local_sensitive_file" "kube_config" {
  content     = azurerm_kubernetes_cluster.aks_k8s.kube_config_raw
  filename = "${path.module}/../${local.project_name}-${local.cluster_name}-kube.conf"
}
