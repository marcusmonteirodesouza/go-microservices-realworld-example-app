data "google_service_account_access_token" "repo" {
  target_service_account = google_service_account.artifactregistry_writer.email
  scopes                 = ["cloud-platform"]
}

provider "google" {
  project = local.project_id
  region  = local.region
}

provider "google-beta" {
  project = local.project_id
  region  = local.region
}

provider "docker" {
  registry_auth {
    address  = local.registry
    username = "oauth2accesstoken"
    password = data.google_service_account_access_token.repo.access_token
  }
}

resource "google_service_account" "artifactregistry_writer" {
  project = local.project_id
  account_id   = "artifact-registry-writer"
}

resource "google_project_iam_member" "artifactregistry_writer" {
  project = local.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.artifactregistry_writer.email}"
}

module "network" {
  source = "../../modules/network"

  project_id               = local.project_id
  region                   = local.region
  subnetwork_ip_cidr_range = local.subnetwork_ip_cidr_range
}

module "firestore" {
  source = "../../modules/firestore"

  project_id  = local.project_id
  location_id = local.firestore_location_id
}

module "users_service" {
  source = "./modules/users_service"

  project_id = local.project_id
  region     = local.region

  depends_on = [
    module.firestore
  ]
}

module "api_gateway" {
  source = "./modules/api_gateway"

  api_id          = local.api_id
  api_description = local.api_description
  users_service_url = module.users_service.url
}
