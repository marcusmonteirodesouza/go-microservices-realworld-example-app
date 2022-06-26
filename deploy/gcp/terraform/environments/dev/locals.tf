locals {
  project_id               = "marcus-go-ms-rw-example-1"
  region                   = "us-central1"
  registry                 = "${local.region}-docker.pkg.dev"
  subnetwork_ip_cidr_range = "10.128.0.0/20"
  firestore_location_id    = "us-central"
  api_id                   = "realworld-example-app"
  api_description          = "RealWorld Example App API"
}
