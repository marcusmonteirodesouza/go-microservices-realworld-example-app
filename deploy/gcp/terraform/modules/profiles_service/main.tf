data "google_project" "project" {
}

data "docker_registry_image" "profiles_service" {
  name = var.image
}

resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_cloud_run_service" "profiles_service" {
  name     = "profiles-service"
  location = var.location

  template {
    spec {
      containers {
        image = "${var.image}@${data.docker_registry_image.profiles_service.sha256_digest}"
        env {
          name  = "FIRESTORE_PROJECT_ID"
          value = data.google_project.project.project_id
        }
        env {
          name  = "USERS_SERVICE_BASE_URL"
          value = var.users_service_base_url
        }
      }
    }
  }

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }

  depends_on = [
    google_project_service.run,
  ]
}

module "external_http_lb" {
  source = "../../modules/cloud_run_external_http_lb"

  network           = var.network
  cloud_run_service = google_cloud_run_service.profiles_service.name
}
