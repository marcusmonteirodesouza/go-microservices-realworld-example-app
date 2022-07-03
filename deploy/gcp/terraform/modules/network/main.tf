resource "google_compute_network" "vpc_network" {
  name                            = "vpc-network"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "default" {
  name          = "default-${var.region}"
  network       = google_compute_network.vpc_network.name
  ip_cidr_range = var.subnetwork_ip_cidr_range
}
