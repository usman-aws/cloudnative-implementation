output "namespace" {
  value = kubernetes_namespace.todo_app.metadata[0].name
}

output "frontend_nodeport" {
  value = 30081
}

output "api_nodeport" {
  value = 30080
}
