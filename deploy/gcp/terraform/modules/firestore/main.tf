resource "google_app_engine_application" "firestore" {
  provider      = google-beta
  location_id   = var.location_id
  database_type = "CLOUD_FIRESTORE"
}
