terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

# ---------------------------------------------------------------------------
# Namespace
# ---------------------------------------------------------------------------
resource "kubernetes_namespace" "todo_app" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = "local"
    }
  }
}

# ---------------------------------------------------------------------------
# Database — Secret, PVC, StatefulSet, Service
# ---------------------------------------------------------------------------
resource "kubernetes_secret" "mongodb" {
  metadata {
    name      = "mongodb-secret"
    namespace = kubernetes_namespace.todo_app.metadata[0].name
    labels = {
      app  = "mongodb"
      tier = "database"
    }
  }
  data = {
    MONGO_INITDB_ROOT_USERNAME = base64encode(var.db_user)
    MONGO_INITDB_ROOT_PASSWORD = base64encode(var.db_pass)
    MONGO_INITDB_DATABASE      = base64encode(var.db_name)
  }
  type = "Opaque"
}

resource "kubernetes_persistent_volume_claim" "mongodb" {
  metadata {
    name      = "mongodb-pvc"
    namespace = kubernetes_namespace.todo_app.metadata[0].name
    labels = {
      app  = "mongodb"
      tier = "database"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.db_storage_size
      }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_stateful_set" "mongodb" {
  metadata {
    name      = "mongodb"
    namespace = kubernetes_namespace.todo_app.metadata[0].name
    labels = {
      app  = "mongodb"
      tier = "database"
    }
  }
  spec {
    service_name = "mongodb"
    replicas     = 1
    selector {
      match_labels = {
        app  = "mongodb"
        tier = "database"
      }
    }
    template {
      metadata {
        labels = {
          app  = "mongodb"
          tier = "database"
        }
      }
      spec {
        container {
          name              = "mongodb"
          image             = "mongo:4.4"
          image_pull_policy = "IfNotPresent"
          port {
            name           = "mongodb"
            container_port = 27017
            protocol       = "TCP"
          }
          env_from {
            secret_ref {
              name = kubernetes_secret.mongodb.metadata[0].name
            }
          }
          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
          liveness_probe {
            exec {
              command = ["mongo", "--eval", "db.adminCommand('ping')"]
            }
            initial_delay_seconds = 30
            period_seconds        = 15
            timeout_seconds       = 5
            failure_threshold     = 3
          }
          readiness_probe {
            exec {
              command = ["mongo", "--eval", "db.adminCommand('ping')"]
            }
            initial_delay_seconds = 15
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }
          volume_mount {
            name       = "mongodb-data"
            mount_path = "/data/db"
          }
        }
        volume {
          name = "mongodb-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mongodb.metadata[0].name
          }
        }
      }
    }
  }
  depends_on = [kubernetes_secret.mongodb, kubernetes_persistent_volume_claim.mongodb]
}

resource "kubernetes_service" "mongodb" {
  metadata {
    name      = "mongodb"
    namespace = kubernetes_namespace.todo_app.metadata[0].name
    labels = {
      app  = "mongodb"
      tier = "database"
    }
  }
  spec {
    type = "ClusterIP"
    selector = {
      app  = "mongodb"
      tier = "database"
    }
    port {
      name        = "mongodb"
      port        = 27017
      target_port = "mongodb"
      protocol    = "TCP"
    }
  }
}

# ---------------------------------------------------------------------------
# API — Secret, ServiceAccount, Deployment, Services
# ---------------------------------------------------------------------------
resource "kubernetes_secret" "todo_api" {
  metadata {
    name      = "todo-api-secret"
    namespace = kubernetes_namespace.todo_app.metadata[0].name
    labels = {
      app  = "todo-api"
      tier = "backend"
    }
  }
  data = {
    DB_CONNECTION = base64encode("mongodb://${var.db_user}:${var.db_pass}@mongodb:27017/${var.db_name}?authSource=admin")
    DB_NAME       = base64encode(var.db_name)
  }
  type = "Opaque"
}

resource "kubernetes_service_account" "todo_api" {
  metadata {
    name      = "todo-api-sa"
    namespace = kubernetes_namespace.todo_app.metadata[0].name
  }
  automount_service_account_token = false
}

resource "kubernetes_deployment" "todo_api" {
  metadata {
    name      = "todo-api"
    namespace = kubernetes_namespace.todo_app.metadata[0].name
    labels = {
      app  = "todo-api"
      tier = "backend"
    }
  }
  spec {
    replicas = var.api_replica_count
    selector {
      match_labels = {
        app  = "todo-api"
        tier = "backend"
      }
    }
    template {
      metadata {
        labels = {
          app  = "todo-api"
          tier = "backend"
        }
      }
      spec {
        service_account_name            = kubernetes_service_account.todo_api.metadata[0].name
        automount_service_account_token = false
        security_context {
          run_as_user     = 1001
          run_as_non_root = true
          fs_group        = 2000
        }
        container {
          name              = "todo-api"
          image             = "${var.dockerhub_username}/go-to-do-api:${var.api_image_tag}"
          image_pull_policy = "Always"
          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }
          env_from {
            secret_ref {
              name = kubernetes_secret.todo_api.metadata[0].name
            }
          }
          resources {
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "250m"
              memory = "128Mi"
            }
          }
          liveness_probe {
            http_get {
              path = "/healthz"
              port = "http"
            }
            initial_delay_seconds = 10
            period_seconds        = 15
            timeout_seconds       = 5
            failure_threshold     = 3
          }
          readiness_probe {
            http_get {
              path = "/api/task"
              port = "http"
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }
        }
      }
    }
  }
  depends_on = [kubernetes_stateful_set.mongodb, kubernetes_secret.todo_api]
}

resource "kubernetes_service" "todo_api" {
  metadata {
    name      = "todo-api"
    namespace = kubernetes_namespace.todo_app.metadata[0].name
    labels = {
      app  = "todo-api"
      tier = "backend"
    }
  }
  spec {
    type = "ClusterIP"
    selector = {
      app  = "todo-api"
      tier = "backend"
    }
    port {
      name        = "http"
      port        = 80
      target_port = "http"
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_service" "todo_api_nodeport" {
  metadata {
    name      = "todo-api-nodeport"
    namespace = kubernetes_namespace.todo_app.metadata[0].name
    labels = {
      app  = "todo-api"
      tier = "backend"
    }
  }
  spec {
    type = "NodePort"
    selector = {
      app  = "todo-api"
      tier = "backend"
    }
    port {
      name        = "http"
      port        = 80
      target_port = "http"
      node_port   = 30080
      protocol    = "TCP"
    }
  }
}

# ---------------------------------------------------------------------------
# Frontend — Secret, ServiceAccount, Deployment, Service
# ---------------------------------------------------------------------------
resource "kubernetes_secret" "todo_frontend" {
  metadata {
    name      = "todo-frontend-secret"
    namespace = kubernetes_namespace.todo_app.metadata[0].name
    labels = {
      app  = "todo-frontend"
      tier = "frontend"
    }
  }
  data = {
    REACT_APP_API_ENDPOINT = base64encode(var.react_app_api_endpoint)
  }
  type = "Opaque"
}

resource "kubernetes_service_account" "todo_frontend" {
  metadata {
    name      = "todo-frontend-sa"
    namespace = kubernetes_namespace.todo_app.metadata[0].name
  }
  automount_service_account_token = false
}

resource "kubernetes_deployment" "todo_frontend" {
  metadata {
    name      = "todo-frontend"
    namespace = kubernetes_namespace.todo_app.metadata[0].name
    labels = {
      app  = "todo-frontend"
      tier = "frontend"
    }
  }
  spec {
    replicas = var.frontend_replica_count
    selector {
      match_labels = {
        app  = "todo-frontend"
        tier = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          app  = "todo-frontend"
          tier = "frontend"
        }
      }
      spec {
        service_account_name            = kubernetes_service_account.todo_frontend.metadata[0].name
        automount_service_account_token = false
        security_context {
          run_as_user     = 1001
          run_as_non_root = true
        }
        init_container {
          name  = "env-generator"
          image = "abdennour/dotenv-to-js-object:4ea"
          args  = ["--dest=/data", "--env-vars-filter=REACT_APP_", "--run-as=job"]
          env_from {
            secret_ref {
              name = kubernetes_secret.todo_frontend.metadata[0].name
            }
          }
          volume_mount {
            name       = "env-js"
            mount_path = "/data"
          }
        }
        container {
          name              = "todo-frontend"
          image             = "${var.dockerhub_username}/go-to-do-frontend:${var.frontend_image_tag}"
          image_pull_policy = "Always"
          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }
          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
          }
          liveness_probe {
            http_get {
              path = "/"
              port = "http"
            }
            initial_delay_seconds = 10
            period_seconds        = 15
          }
          readiness_probe {
            http_get {
              path = "/"
              port = "http"
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
          volume_mount {
            name       = "env-js"
            mount_path = "/opt/app/config"
            read_only  = true
          }
        }
        volume {
          name = "env-js"
          empty_dir {}
        }
      }
    }
  }
  depends_on = [kubernetes_deployment.todo_api, kubernetes_secret.todo_frontend]
}

resource "kubernetes_service" "todo_frontend" {
  metadata {
    name      = "todo-frontend"
    namespace = kubernetes_namespace.todo_app.metadata[0].name
    labels = {
      app  = "todo-frontend"
      tier = "frontend"
    }
  }
  spec {
    type = "NodePort"
    selector = {
      app  = "todo-frontend"
      tier = "frontend"
    }
    port {
      name        = "http"
      port        = 80
      target_port = "http"
      node_port   = 30081
      protocol    = "TCP"
    }
  }
}

# ---------------------------------------------------------------------------
# Network Policies
# ---------------------------------------------------------------------------
resource "kubernetes_network_policy" "default_deny_ingress" {
  metadata {
    name      = "default-deny-ingress"
    namespace = kubernetes_namespace.todo_app.metadata[0].name
  }
  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "allow_api_to_db" {
  metadata {
    name      = "allow-api-to-db"
    namespace = kubernetes_namespace.todo_app.metadata[0].name
  }
  spec {
    pod_selector {
      match_labels = {
        app  = "mongodb"
        tier = "database"
      }
    }
    policy_types = ["Ingress"]
    ingress {
      from {
        pod_selector {
          match_labels = {
            app  = "todo-api"
            tier = "backend"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = "27017"
      }
    }
  }
}

resource "kubernetes_network_policy" "allow_frontend_to_api" {
  metadata {
    name      = "allow-frontend-to-api"
    namespace = kubernetes_namespace.todo_app.metadata[0].name
  }
  spec {
    pod_selector {
      match_labels = {
        app  = "todo-api"
        tier = "backend"
      }
    }
    policy_types = ["Ingress"]
    ingress {
      from {
        pod_selector {
          match_labels = {
            app  = "todo-frontend"
            tier = "frontend"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = "8080"
      }
    }
    ingress {
      ports {
        protocol = "TCP"
        port     = "8080"
      }
    }
  }
}

resource "kubernetes_network_policy" "allow_external_to_frontend" {
  metadata {
    name      = "allow-external-to-frontend"
    namespace = kubernetes_namespace.todo_app.metadata[0].name
  }
  spec {
    pod_selector {
      match_labels = {
        app  = "todo-frontend"
        tier = "frontend"
      }
    }
    policy_types = ["Ingress"]
    ingress {
      ports {
        protocol = "TCP"
        port     = "8080"
      }
    }
  }
}
