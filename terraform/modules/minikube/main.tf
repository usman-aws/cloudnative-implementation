terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

resource "null_resource" "minikube" {
  triggers = {
    cluster_name       = var.cluster_name
    driver             = var.driver
    memory             = var.memory
    cpus               = var.cpus
    kubernetes_version = var.kubernetes_version
  }

  provisioner "local-exec" {
    command = "minikube start --profile=${var.cluster_name} --driver=${var.driver} --memory=${var.memory} --cpus=${var.cpus} --kubernetes-version=${var.kubernetes_version} --cni=calico --force; minikube update-context --profile=${var.cluster_name}"
  }
}
