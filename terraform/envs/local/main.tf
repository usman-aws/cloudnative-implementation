terraform {
  required_version = ">= 1.5.0"

  required_providers {
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "~> 0.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

module "minikube" {
  source             = "../../modules/minikube"
  cluster_name       = var.cluster_name
  driver             = var.driver
  memory             = var.memory
  cpus               = var.cpus
  kubernetes_version = var.kubernetes_version
  addons             = var.addons
}

provider "kubernetes" {
  host                   = module.minikube.host
  client_certificate     = base64decode(module.minikube.client_certificate)
  client_key             = base64decode(module.minikube.client_key)
  cluster_ca_certificate = base64decode(module.minikube.cluster_ca_certificate)
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
  react_app_api_endpoint = "http://${module.minikube.host}:30080"
  depends_on             = [module.minikube]
}
