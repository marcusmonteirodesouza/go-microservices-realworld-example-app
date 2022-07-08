data "google_client_config" "deployer" {
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

provider "docker" {
  registry_auth {
    address  = local.registry
    username = "oauth2accesstoken"
    password = data.google_client_config.deployer.access_token
  }
}

module "users_service" {
  source = "../../modules/users_service"


  location = var.region
  image    = var.users_service_image
}

module "api_gateway" {
  source = "../../modules/api_gateway"

  api_id            = local.api_id
  api_description   = local.api_description
  users_service_url = module.users_service.url
}
