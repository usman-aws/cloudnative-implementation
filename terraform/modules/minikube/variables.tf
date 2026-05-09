variable "cluster_name" {
  description = "Name of the Minikube cluster"
  type        = string
  default     = "todo-app"
}

variable "driver" {
  description = "Minikube VM driver (docker, virtualbox, hyperkit)"
  type        = string
  default     = "docker"
}

variable "memory" {
  description = "Memory (MB) for the Minikube node"
  type        = string
  default     = "4096"
}

variable "cpus" {
  description = "Number of CPUs for the Minikube node"
  type        = number
  default     = 2
}

variable "kubernetes_version" {
  description = "Kubernetes version (e.g. 'v1.28.0')"
  type        = string
  default     = "v1.28.0"
}

variable "addons" {
  description = "Minikube addons to enable"
  type        = list(string)
  default     = ["default-storageclass", "storage-provisioner"]
}
