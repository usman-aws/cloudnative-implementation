variable "cluster_name"       { type = string; default = "todo-app" }
variable "driver"             { type = string; default = "docker" }
variable "memory"             { type = string; default = "4096" }
variable "cpus"               { type = number; default = 2 }
variable "kubernetes_version" { type = string; default = "v1.28.0" }
variable "addons"             { type = list(string); default = ["default-storageclass", "storage-provisioner"] }
variable "namespace"          { type = string; default = "todo-app" }
variable "dockerhub_username" { type = string }
variable "api_image_tag"          { type = string; default = "latest" }
variable "frontend_image_tag"     { type = string; default = "latest" }
variable "db_root_pass"       { type = string; sensitive = true; default = "adminpass" }
variable "db_user"            { type = string; default = "appuser" }
variable "db_pass"            { type = string; sensitive = true; default = "apppass" }
variable "db_name"            { type = string; default = "test" }
variable "db_storage_size"    { type = string; default = "1Gi" }
variable "api_replica_count"      { type = number; default = 2 }
variable "frontend_replica_count" { type = number; default = 2 }
