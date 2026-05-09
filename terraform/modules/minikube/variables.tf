variable "cluster_name" {
  type    = string
  default = "minikube"
}

variable "driver" {
  type    = string
  default = "docker"
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "cpus" {
  type    = number
  default = 2
}

variable "kubernetes_version" {
  type    = string
  default = "v1.28.0"
}

variable "addons" {
  type    = list(string)
  default = ["default-storageclass", "storage-provisioner"]
}
