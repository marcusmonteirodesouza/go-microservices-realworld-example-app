resource "google_compute_region_network_endpoint_group" "api_gateway" {
  provider = google-beta

  name                  = "${var.api_gateway_id}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  serverless_deployment {
    platform = "apigateway.googleapis.com"
    resource = var.api_gateway_id
  }
}

resource "google_compute_backend_service" "api_gateway" {
  provider = google-beta

  name = "api-gateway-backend-service"

  backend {
    group = google_compute_region_network_endpoint_group.api_gateway.id
  }
}

resource "google_compute_url_map" "api_gateway" {
  provider = google-beta

  name = "api-gateway-url-map"

  default_service = google_compute_backend_service.api_gateway.id
}

resource "google_compute_target_http_proxy" "api_gateway" {
  provider = google-beta

  name    = "api-gateway-http-proxy"
  url_map = google_compute_url_map.api_gateway.id
}

resource "google_compute_global_address" "api_gateway_lb" {
  provider = google-beta
  name     = "api-gateway-external-http-lb-ip"
}

resource "google_compute_global_forwarding_rule" "api_gateway" {
  provider = google-beta

  name       = "api-gateway-forwarding-rule"
  target     = google_compute_target_http_proxy.api_gateway.id
  ip_address = google_compute_global_address.api_gateway_lb.address
  port_range = "80"
}
