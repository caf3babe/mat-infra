locals {
  project = "mat-project-2110838008"
}

module "spinnaker_cluster" {
  source       = "./lib/aks"
  project_name = local.project
  cluster_name = "spinnaker"
  node_count   = 4
}

# data "azurerm_subscription" "primary" {}
# # azure ad sp
# data "azuread_client_config" "current" {}

# resource "azuread_application" "spinnaker" {
#   display_name = "spinnaker"
#   owners       = [data.azuread_client_config.current.object_id]
# }

# resource "azuread_service_principal" "spinnaker" {
#   application_id               = azuread_application.spinnaker.application_id
#   app_role_assignment_required = false
#   owners                       = [data.azuread_client_config.current.object_id]
# }

# resource "azuread_service_principal_password" "spinnaker" {
#   service_principal_id = azuread_service_principal.spinnaker.object_id
# }

# resource "azurerm_role_assignment" "spinnaker" {
#   scope                = data.azurerm_subscription.primary.id
#   role_definition_name = "Contributor"
#   principal_id         = azuread_service_principal.spinnaker.object_id
# }

# resource "azurerm_resource_group" "spinnaker_config" {
#   name     = join("-", [local.project, "spin-config"])
#   location = "West Europe"
# }

# resource "azurerm_key_vault" "spinnaker_keyvault" {
#   name                            = "spinconfigkeyvault"
#   location                        = azurerm_resource_group.spinnaker_config.location
#   resource_group_name             = azurerm_resource_group.spinnaker_config.name
#   enabled_for_disk_encryption     = true
#   enabled_for_template_deployment = true
#   tenant_id                       = data.azurerm_client_config.current.tenant_id
#   soft_delete_retention_days      = 7
#   purge_protection_enabled        = false

#   sku_name = "standard"
# }

# resource "azurerm_storage_account" "spinnaker_storage" {
#   name                     = "spinconfigstorage"
#   resource_group_name      = azurerm_resource_group.spinnaker_config.name
#   location                 = azurerm_resource_group.spinnaker_config.location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"

# }
