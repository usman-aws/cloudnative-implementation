output "cluster_name" {
  description = "Minikube cluster/profile name"
  value       = var.cluster_name
  depends_on  = [null_resource.minikube]
}

