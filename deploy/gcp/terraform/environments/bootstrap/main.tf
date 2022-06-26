resource "google_project" "realworld_example" {
  name                = var.project_id
  project_id          = var.project_id
  folder_id           = var.folder_id
  billing_account     = var.billing_account
  auto_create_network = false
}

resource "google_storage_bucket" "tfstate" {
  project  = google_project.realworld_example.project_id
  name     = "tfstate-${var.project_id}-${var.environment}"
  location = var.tfstate_bucket_location

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}
