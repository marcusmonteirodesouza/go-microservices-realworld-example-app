resource "google_project" "realworld_example" {
  name                = var.project_id
  project_id          = var.project_id
  folder_id           = var.folder_id
  billing_account     = var.billing_account
  auto_create_network = false
}

# Terraform state bucket
resource "random_pet" "tfstate_bucket" {
}

resource "google_storage_bucket" "tfstate" {
  project  = google_project.realworld_example.project_id
  name     = random_pet.tfstate_bucket.id
  location = var.region

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

# serviceusage is used when enabling the other APIs
resource "google_project_service" "serviceusage" {
  project            = google_project.realworld_example.project_id
  service            = "serviceusage.googleapis.com"
  disable_on_destroy = false
}

# To enable the repository dispatch Cloud Function to be deployed
resource "google_project_service" "cloudfunctions" {
  project            = google_project.realworld_example.project_id
  service            = "cloudfunctions.googleapis.com"
  disable_on_destroy = false
}

# Because only Owner can create App Engine applications https://cloud.google.com/appengine/docs/standard/python/roles#primitive_roles
module "firestore" {
  source = "../../modules/firestore"

  project_id  = google_project.realworld_example.project_id
  location_id = var.firestore_location_id
}

# Artifact registry repositories for the services hosted by this project
resource "google_project_service" "artifactregistry" {
  project            = google_project.realworld_example.project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "users_service" {
  provider = google-beta

  project       = google_project.realworld_example.project_id
  location      = var.region
  repository_id = "users-service-repository"
  description   = "Users Service Repository"
  format        = "DOCKER"

  depends_on = [
    google_project_service.artifactregistry
  ]
}

resource "google_artifact_registry_repository" "profles_service" {
  provider = google-beta

  project       = google_project.realworld_example.project_id
  location      = var.region
  repository_id = "profiles-service-repository"
  description   = "Profiles Service Repository"
  format        = "DOCKER"

  depends_on = [
    google_project_service.artifactregistry
  ]
}

# Creates the Github Deployer Service Account and setups Workload Identity
resource "google_service_account" "github_deployer" {
  project    = google_project.realworld_example.project_id
  account_id = "github-deployer"
}

resource "google_project_service" "cloudbuild" {
  project            = google_project.realworld_example.project_id
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_iam_member" "github_deployer_apigateway_admin" {
  project = google_project.realworld_example.project_id
  role    = "roles/apigateway.admin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_deployer_cloudbuild_builder" {
  project = google_project.realworld_example.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_deployer_compute_instance_admin" {
  project = google_project.realworld_example.project_id
  role    = "roles/compute.instanceAdmin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_deployer_network_admin" {
  project = google_project.realworld_example.project_id
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_deployer_quota_admin" {
  project = google_project.realworld_example.project_id
  role    = "roles/servicemanagement.quotaAdmin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_deployer_run_admin" {
  project = google_project.realworld_example.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_deployer_security_admin" {
  project = google_project.realworld_example.project_id
  role    = "roles/compute.securityAdmin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

# TODO: Create a custom role with only create and delete secrets permissions.
resource "google_project_iam_member" "github_deployer_secretmanager_admin" {
  project = google_project.realworld_example.project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_deployer_service_account_user" {
  project = google_project.realworld_example.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_deployer_service_usage_admin" {
  project = google_project.realworld_example.project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_service" "iam" {
  project            = google_project.realworld_example.project_id
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudresourcemanager" {
  project            = google_project.realworld_example.project_id
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iamcredentials" {
  project            = google_project.realworld_example.project_id
  service            = "iamcredentials.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "sts" {
  project            = google_project.realworld_example.project_id
  service            = "sts.googleapis.com"
  disable_on_destroy = false
}

module "github_oidc" {
  source      = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id  = google_project.realworld_example.project_id
  pool_id     = "github-pool"
  provider_id = "github-provider"
  sa_mapping = {
    "github-deployer" = {
      sa_name   = google_service_account.github_deployer.id
      attribute = "*"
    }
  }

  depends_on = [
    google_project_service.iam,
    google_project_service.cloudresourcemanager,
    google_project_service.iamcredentials,
    google_project_service.sts
  ]
}
