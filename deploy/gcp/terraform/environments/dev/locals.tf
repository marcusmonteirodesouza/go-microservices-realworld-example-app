locals {
  project_id               = "marcus-go-ms-rw-example-1"
  region                   = "us-central1"
  registry                 = "${local.region}-docker.pkg.dev"
  subnetwork_ip_cidr_range = "10.128.0.0/20"
  firestore_location_id    = "us-central"
  users_service_image      = "${local.region}-docker.pkg.dev/${local.project_id}/users-service-repository/users-service"
  api_id                   = "realworld-example-app-api"
  api_description          = "RealWorld Example App API"
}
