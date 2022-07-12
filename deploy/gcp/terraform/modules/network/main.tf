resource "google_compute_network" "default" {
  provider = google-beta

  name                            = "default"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
  routing_mode                    = "REGIONAL"
}

resource "google_compute_subnetwork" "lb" {
  provider = google-beta

  name          = "lb"
  ip_cidr_range = var.lb_ip_cidr_range
  purpose       = "PRIVATE"
  network       = google_compute_network.default.id
}

resource "google_compute_subnetwork" "proxy_only" {
  provider = google-beta

  name          = "proxy-only"
  ip_cidr_range = var.proxy_only_ip_cidr_range
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.default.id
}
