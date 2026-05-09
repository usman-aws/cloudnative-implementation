output "cluster_name"  { value = module.minikube.cluster_name }
output "minikube_host" { value = module.minikube.host }
output "frontend_url"  { value = "http://${module.minikube.host}:${module.k8s_manifests.frontend_nodeport}" }
output "api_url"       { value = "http://${module.minikube.host}:${module.k8s_manifests.api_nodeport}/api/task" }
output "namespace"     { value = module.k8s_manifests.namespace }
