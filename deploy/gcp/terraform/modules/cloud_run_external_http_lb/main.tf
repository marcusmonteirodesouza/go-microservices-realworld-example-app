data "google_client_config" "deployer" {
}

resource "google_compute_region_network_endpoint_group" "cloud_run" {
  provider = google-beta

  name                  = "${var.cloud_run_service}-cloud-run-neg"
  region                = data.google_client_config.deployer.region
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = var.cloud_run_service
  }
}

resource "google_compute_region_backend_service" "cloud_run" {
  provider = google-beta

  name                  = "${var.cloud_run_service}-backend-service"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group           = google_compute_region_network_endpoint_group.cloud_run.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_region_url_map" "cloud_run" {
  provider = google-beta

  name = "${var.cloud_run_service}-url-map"

  default_service = google_compute_region_backend_service.cloud_run.id
}

resource "google_compute_region_target_http_proxy" "cloud_run" {
  provider = google-beta

  name    = "${var.cloud_run_service}-target-http-proxy"
  url_map = google_compute_region_url_map.cloud_run.id
}

resource "google_compute_address" "load_balancer" {
  provider = google-beta

  name         = "${var.cloud_run_service}-external-http-lb"
  address_type = "EXTERNAL"
  network_tier = "STANDARD"
}

resource "google_compute_forwarding_rule" "cloud_run" {
  provider = google-beta

  name                  = "${var.cloud_run_service}-external-http-lb"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  network               = var.network
  ip_protocol           = "TCP"
  ip_address            = google_compute_address.load_balancer.address
  target                = google_compute_region_target_http_proxy.cloud_run.id
  port_range            = "80"
  network_tier          = "STANDARD"
}
