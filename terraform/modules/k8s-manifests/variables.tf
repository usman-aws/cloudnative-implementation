variable "namespace" {
  type    = string
  default = "todo-app"
}

variable "dockerhub_username" {
  description = "Docker Hub username — images: username/go-to-do-api, username/go-to-do-frontend"
  type        = string
}

variable "api_image_tag" {
  type    = string
  default = "latest"
}

variable "frontend_image_tag" {
  type    = string
  default = "latest"
}

variable "db_root_pass" {
  type      = string
  sensitive = true
  default   = "adminpass"
}

variable "db_user" {
  type    = string
  default = "appuser"
}

variable "db_pass" {
  type      = string
  sensitive = true
  default   = "apppass"
}

variable "db_name" {
  type    = string
  default = "test"
}

variable "db_storage_size" {
  type    = string
  default = "1Gi"
}

variable "api_replica_count" {
  type    = number
  default = 2
}

variable "frontend_replica_count" {
  type    = number
  default = 2
}

variable "react_app_api_endpoint" {
  description = "API URL visible to the browser — format: http://<minikube-ip>:30080"
  type        = string
}
