data "google_project" "project" {
}

data "docker_registry_image" "users_service" {
  name = var.image
}

resource "random_password" "users_service_jwt_secret_key" {
  length = 64
}

resource "google_project_service" "secretmanager" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_secret_manager_secret" "users_service_jwt_secret_key" {
  secret_id = "users-service-jwt-key"

  replication {
    automatic = true
  }

  depends_on = [
    google_project_service.secretmanager
  ]
}

resource "google_secret_manager_secret_version" "users_service_jwt_secret_key" {
  secret = google_secret_manager_secret.users_service_jwt_secret_key.id

  secret_data = random_password.users_service_jwt_secret_key.result
}

resource "google_secret_manager_secret_iam_member" "secret_access" {
  secret_id = google_secret_manager_secret.users_service_jwt_secret_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}

resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_cloud_run_service" "users_service" {
  name     = "users-service"
  location = var.location

  template {
    spec {
      containers {
        image = "${var.image}@${data.docker_registry_image.users_service.sha256_digest}"
        env {
          name  = "FIRESTORE_PROJECT_ID"
          value = data.google_project.project.project_id
        }
        env {
          name = "JWT_SECRET_KEY"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.users_service_jwt_secret_key.secret_id
              key  = "latest"
            }
          }
        }
        env {
          name  = "JWT_SECONDS_TO_EXPIRE"
          value = var.jwt_seconds_to_expire
        }
      }
    }
  }

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "all"
    }
  }

  depends_on = [
    google_project_service.run,
    google_secret_manager_secret_iam_member.secret_access,
  ]
}

resource "google_cloud_run_service_iam_member" "run_allow_unauthenticated" {
  location = google_cloud_run_service.users_service.location
  service  = google_cloud_run_service.users_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
