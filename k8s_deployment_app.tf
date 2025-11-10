/*
resource "kubernetes_deployment" "app" {
  metadata {
    name = "app"
    labels = {
      app = "app-sec"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "app-sec"
      }
    }
    template {
      metadata {
        labels = {
          app = "app-sec"
        }
      }
      spec {
        container {
          name  = "app"
          image = "${aws_ecr_repository.app.repository_url}:latest"

          env_from {
            secret_ref {
              name = kubernetes_secret.db_credentials.metadata[0].name
            }
          }

          port {
            container_port = 80
          }
        }
      }
    }
  }
  depends_on = [
#    null_resource.trigger_codebuild, #re-enable it after testing
    aws_eks_cluster.security, #test1 -last 2 delete
    kubernetes_service_account.alb_controller,
  ]
}
*/

/*
##test
resource "kubernetes_service" "app_lb" {
  metadata {
    name = "app-lb"
    labels = {
      app = "app-sec"
    }
  }

  spec {
    selector = {
      app = "app-sec"
    }

    port {
      port        = 80        # Service port (external)
      target_port = 80        # Container port
      protocol    = "TCP"
    }

    type = "LoadBalancer"     # This triggers creation of a Classic ELB in AWS
  }

  depends_on = [
    kubernetes_deployment.app,
  ]
}*/

/*
#test
###########
resource "kubernetes_service" "app_service" {
  metadata {
    name = "app-service"
  }

  spec {
    selector = {
      app = "app-sec"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "app_ingress" {
  metadata {
    name = "app-ingress"
    annotations = {
      "kubernetes.io/ingress.class"                 = "alb"
      "alb.ingress.kubernetes.io/scheme"            = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"       = "ip"
      "alb.ingress.kubernetes.io/listen-ports"      = [{"HTTP":80}]
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = kubernetes_service.app_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service.app_service,
    kubernetes_service_account.alb_controller
  ]
}
*/

resource "kubernetes_deployment" "app" {
  metadata {
    name = "app"
    labels = {
      app = "app-sec"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "app-sec"
      }
    }
    template {
      metadata {
        labels = {
          app = "app-sec"
        }
      }
      spec {
        container {
          name  = "app"
          image = "${aws_ecr_repository.app.repository_url}:latest"

          env_from {
            secret_ref {
              name = kubernetes_secret.db_credentials.metadata[0].name
            }
          }

          port {
            container_port = 80
          }
        }
      }
    }
  }
  depends_on = [
    #null_resource.trigger_codebuild, # re-enable after testing
    aws_eks_cluster.security,
    kubernetes_service_account.alb_controller,
  ]
}

resource "kubernetes_service" "app_service" {
  metadata {
    name = "app-service"
  }

  spec {
    selector = {
      app = "app-sec"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP" # ALB routes to pod IPs, NodePort not needed
  }
}

resource "kubernetes_ingress_v1" "app_ingress" {
  metadata {
    name = "app-ingress"
    annotations = {
      "kubernetes.io/ingress.class"            = "alb"
      "alb.ingress.kubernetes.io/scheme"       = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"  = "ip"
      "alb.ingress.kubernetes.io/listen-ports" = jsonencode([{ "HTTP" : 80 }])
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = kubernetes_service.app_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service.app_service,
    kubernetes_service_account.alb_controller
  ]
}
