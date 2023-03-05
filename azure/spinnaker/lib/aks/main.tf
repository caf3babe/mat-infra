variable "project_name" {
    default = "mat-project-2110838008"
}

variable "cluster_name" {
    default = "cluster-prod"
}

variable "node_count" {
    default = 2
}

resource "azurerm_resource_group" "rg_cluster_prod" {
  name     = join("-", [var.project_name, var.cluster_name])
  location = "West Europe"
}

resource "azurerm_network_watcher" "nw_watcher_cluster_prod" {
  name                = join("-", [var.project_name, var.cluster_name, "nwwatcher"])
  location            = azurerm_resource_group.rg_cluster_prod.location
  resource_group_name = azurerm_resource_group.rg_cluster_prod.name
}

resource "azurerm_kubernetes_cluster" "aks_cluster_prod" {
  name                = join("-", ["aks", var.cluster_name])
  location            = azurerm_resource_group.rg_cluster_prod.location
  resource_group_name = azurerm_resource_group.rg_cluster_prod.name
  dns_prefix          = join("-", [var.project_name, var.cluster_name])
  node_resource_group = join("-", [azurerm_resource_group.rg_cluster_prod.name, "aks-managed"])

  default_node_pool {
    name       = "default"
    node_count = var.node_count
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
  content     = azurerm_kubernetes_cluster.aks_cluster_prod.kube_config.0.client_certificate
  filename = "${path.root}/../kube_client.crt"
}

resource "local_sensitive_file" "kube_config" {
  content     = azurerm_kubernetes_cluster.aks_cluster_prod.kube_config_raw
  filename = "${path.root}/../${var.project_name}-${var.cluster_name}-kube.conf"
}
