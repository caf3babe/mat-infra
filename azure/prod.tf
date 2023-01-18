locals {
  project_name = "mat-project-2110838008"
  cluster_name = "prod"
}

resource "azurerm_resource_group" "rg_prod" {
  name     = join("-", [local.project_name, local.cluster_name])
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "aks_prod" {
  name                = "aks-prod"
  location            = azurerm_resource_group.rg_prod.location
  resource_group_name = azurerm_resource_group.rg_prod.name
  dns_prefix          = join("-", [local.project_name, local.cluster_name])

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D11_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks_prod.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_prod.kube_config_raw

  sensitive = true
}