terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "todo-app"
}

module "k8s_manifests" {
  source                 = "../../modules/k8s-manifests"
  namespace              = var.namespace
  dockerhub_username     = var.dockerhub_username
  api_image_tag          = var.api_image_tag
  frontend_image_tag     = var.frontend_image_tag
  db_root_pass           = var.db_root_pass
  db_user                = var.db_user
  db_pass                = var.db_pass
  db_name                = var.db_name
  db_storage_size        = var.db_storage_size
  api_replica_count      = var.api_replica_count
  frontend_replica_count = var.frontend_replica_count
  react_app_api_endpoint = "http://192.168.49.2:30080"
}
