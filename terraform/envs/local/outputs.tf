output "cluster_name" {
  description = "Minikube cluster name"
  value       = module.minikube.cluster_name
}

output "minikube_host" {
  description = "Kubernetes API server host"
  value       = module.minikube.host
}

output "frontend_url" {
  description = "URL to access the frontend in your browser"
  value       = "http://${module.minikube.host}:${module.k8s_manifests.frontend_nodeport}"
}

output "api_url" {
  description = "URL to access the API directly"
  value       = "http://${module.minikube.host}:${module.k8s_manifests.api_nodeport}/api/task"
}

output "namespace" {
  description = "Kubernetes namespace used"
  value       = module.k8s_manifests.namespace
}
