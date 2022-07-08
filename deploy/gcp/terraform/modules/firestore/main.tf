resource "google_project_service" "appengine" {
  project            = var.project_id
  service            = "appengine.googleapis.com"
  disable_on_destroy = false
}

resource "google_app_engine_application" "firestore" {
  provider      = google-beta
  project       = var.project_id
  location_id   = var.location_id
  database_type = "CLOUD_FIRESTORE"

  depends_on = [
    google_project_service.appengine
  ]
}
