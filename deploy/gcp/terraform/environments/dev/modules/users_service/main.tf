data "google_project" "project" {
}

data "docker_registry_image" "users_service" {
  name = var.image
}

resource "random_password" "users_service_jwt_secret_key" {
  length = 64
}

resource "google_secret_manager_secret" "users_service_jwt_secret_key" {
  secret_id = "users-service-jwt-key"

  replication {
    automatic = true
  }
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

resource "google_cloud_run_service" "users_service" {
  name     = "users-service"
  location = var.region

  template {
    spec {
      containers {
        image = "${var.image}@${data.docker_registry_image.users_service.sha256_digest}"
        env {
          name  = "FIRESTORE_PROJECT_ID"
          value = var.project_id
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

  depends_on = [
    google_secret_manager_secret_iam_member.secret_access,
  ]
}
