provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

resource "google_project_service" "firestore" {
  service                    = "firestore.googleapis.com"
  disable_dependent_services = true
}

resource "google_app_engine_application" "firestore" {
  provider      = google-beta
  location_id   = var.location_id
  database_type = "CLOUD_FIRESTORE"
}
