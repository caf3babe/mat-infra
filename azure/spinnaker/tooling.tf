module "spinnaker_cluster" {
  source       = "./lib/aks"
  project_name = "mat-project-2110838008"
  cluster_name = "spinnaker-tooling"
  node_count   = 2
}