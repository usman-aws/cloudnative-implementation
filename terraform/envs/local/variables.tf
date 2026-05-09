variable "cluster_name" {
  description = "Name of the Minikube cluster"
  type        = string
  default     = "todo-app"
}

variable "driver" {
  description = "Minikube VM driver"
  type        = string
  default     = "docker"
}

variable "memory" {
  description = "Memory in MB for the Minikube node"
  type        = string
  default     = "4096"
}

variable "cpus" {
  description = "CPUs for the Minikube node"
  type        = number
  default     = 2
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "v1.28.0"
}

variable "addons" {
  description = "Minikube addons to enable"
  type        = list(string)
  default     = ["default-storageclass", "storage-provisioner"]
}

variable "namespace" {
  description = "Kubernetes namespace for the app"
  type        = string
  default     = "todo-app"
}

variable "dockerhub_username" {
  description = "Docker Hub username"
  type        = string
}

variable "api_image_tag" {
  description = "API Docker image tag"
  type        = string
  default     = "latest"
}

variable "frontend_image_tag" {
  description = "Frontend Docker image tag"
  type        = string
  default     = "latest"
}

variable "db_root_pass" {
  description = "MongoDB root password"
  type        = string
  sensitive   = true
  default     = "adminpass"
}

variable "db_user" {
  description = "MongoDB application user"
  type        = string
  default     = "appuser"
}

variable "db_pass" {
  description = "MongoDB application password"
  type        = string
  sensitive   = true
  default     = "apppass"
}

variable "db_name" {
  description = "MongoDB database name"
  type        = string
  default     = "test"
}

variable "db_storage_size" {
  description = "PVC size for MongoDB"
  type        = string
  default     = "1Gi"
}

variable "api_replica_count" {
  description = "Number of API replicas"
  type        = number
  default     = 2
}

variable "frontend_replica_count" {
  description = "Number of frontend replicas"
  type        = number
  default     = 2
}
