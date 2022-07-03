data "google_service_account_access_token" "repo" {
  target_service_account = google_service_account.artifactregistry_admin.email
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

module "services" {
  source = "../../modules/services"
}

resource "google_service_account" "artifactregistry_admin" {
  project    = local.project_id
  account_id = "artifact-registry-admin"

  depends_on = [
    module.services
  ]
}

resource "google_project_iam_member" "artifactregistry_admin" {
  project = local.project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.artifactregistry_admin.email}"
}

module "network" {
  source = "../../modules/network"

  project_id               = local.project_id
  region                   = local.region
  subnetwork_ip_cidr_range = local.subnetwork_ip_cidr_range

  depends_on = [
    module.services
  ]
}

module "firestore" {
  source = "../../modules/firestore"

  project_id  = local.project_id
  location_id = local.firestore_location_id

  depends_on = [
    module.services
  ]
}

module "users_service" {
  source = "./modules/users_service"

  project_id = local.project_id
  region     = local.region
  image      = local.users_service_image

  depends_on = [
    module.services,
    module.firestore,
    google_project_iam_member.artifactregistry_admin
  ]
}

module "api_gateway" {
  source = "./modules/api_gateway"

  api_id            = local.api_id
  api_description   = local.api_description
  users_service_url = module.users_service.url

  depends_on = [
    module.services
  ]
}
