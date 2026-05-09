output "frontend_url" {
  value = "http://192.168.49.2:${module.k8s_manifests.frontend_nodeport}"
}

output "api_url" {
  value = "http://192.168.49.2:${module.k8s_manifests.api_nodeport}/api/task"
}

output "namespace" {
  value = module.k8s_manifests.namespace
}
