resource "google_project" "realworld_example" {
  name                = var.project_id
  project_id          = var.project_id
  folder_id           = var.folder_id
  billing_account     = var.billing_account
  auto_create_network = false
}

# serviceusage is used when enabling the other APIs
resource "google_project_service" "serviceusage" {
  project = google_project.realworld_example.project_id
  service = "serviceusage.googleapis.com"
}

# Terraform state bucket
resource "google_storage_bucket" "tfstate" {
  project  = google_project.realworld_example.project_id
  name     = "tfstate-${var.project_id}-${var.environment}"
  location = var.region

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
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

# Creates the Github Deployer Service Account and setups Workload Identity
# TODO(Marcus): Replace these wide roles by a custom role with only the necessary permissions.
resource "google_service_account" "github_deployer" {
  project    = google_project.realworld_example.project_id
  account_id = "github-deployer"
}

resource "google_project_iam_member" "github_deployer_apigateway_admin" {
  project = google_project.realworld_example.project_id
  role    = "roles/apigateway.admin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_deployer_appengine_admin" {
  project = google_project.realworld_example.project_id
  role    = "roles/appengine.appAdmin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_deployer_cloudbuild_service_agent" {
  project = google_project.realworld_example.project_id
  role    = "roles/cloudbuild.serviceAgent"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_deployer_service_account_admin" {
  project = google_project.realworld_example.project_id
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_deployer_workload_identity_pool_admin" {
  project = google_project.realworld_example.project_id
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_deployer_project_iam_admin" {
  project = google_project.realworld_example.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_deployer_run_admin" {
  project = google_project.realworld_example.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_deployer_secretmanager_admin" {
  project = google_project.realworld_example.project_id
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
}

resource "google_project_iam_member" "github_deployer_quota_admin" {
  project = google_project.realworld_example.project_id
  role    = "roles/servicemanagement.quotaAdmin"
  member  = "serviceAccount:${google_service_account.github_deployer.email}"
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
    google_project_iam_member.github_deployer_workload_identity_pool_admin,
    google_project_iam_member.github_deployer_service_account_admin
  ]
}
