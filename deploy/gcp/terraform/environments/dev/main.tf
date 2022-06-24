provider "google" {
  project = local.project_id
  region  = local.region
}

provider "google-beta" {
  project = local.project_id
  region  = local.region
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
