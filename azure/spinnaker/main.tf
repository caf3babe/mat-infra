locals {
  project = "mat-project-2110838008"
}

module "spinnaker_cluster" {
  source       = "./lib/aks"
  project_name = local.project
  cluster_name = "spinnaker"
  node_count   = 4
}
