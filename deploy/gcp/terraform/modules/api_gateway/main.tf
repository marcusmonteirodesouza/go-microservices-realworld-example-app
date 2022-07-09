resource "google_project_service" "apigateway" {
  service            = "apigateway.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "servicecontrol" {
  service            = "servicecontrol.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "servicemanagement" {
  service            = "servicemanagement.googleapis.com"
  disable_on_destroy = false
}

resource "google_api_gateway_api" "api" {
  provider = google-beta
  api_id   = var.api_id

  depends_on = [
    google_project_service.apigateway
  ]
}

resource "random_string" "api_config_id" {
  length  = 4
  upper   = false
  special = false

  keepers = {
    api_config_spec = local.api_config_spec
  }
}

resource "google_api_gateway_api_config" "api_gateway" {
  provider      = google-beta
  api           = google_api_gateway_api.api.api_id
  api_config_id = "${google_api_gateway_api.api.api_id}-config-${random_string.api_config_id.result}"

  openapi_documents {
    document {
      path     = "realworld-example-app-spec.yaml"
      contents = base64encode(local.api_config_spec)
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    google_project_service.apigateway
  ]
}

resource "google_api_gateway_gateway" "api_gateway" {
  provider   = google-beta
  api_config = google_api_gateway_api_config.api_gateway.id
  gateway_id = "${var.api_id}-api-gateway"
}
