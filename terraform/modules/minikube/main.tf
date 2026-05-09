terraform {
  required_providers {
    minikube = {
      source  = "scott-the-programmer/minikube"
      version = "~> 0.4"
    }
  }
}

resource "minikube_cluster" "this" {
  cluster_name       = var.cluster_name
  driver             = var.driver
  memory             = var.memory
  cpus               = var.cpus
  kubernetes_version = var.kubernetes_version
  addons             = var.addons
}
