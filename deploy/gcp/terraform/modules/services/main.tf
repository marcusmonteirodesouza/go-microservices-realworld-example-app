resource "google_project_service" "api_gateway" {
  service = "apigateway.googleapis.com"
}

resource "google_project_service" "appengine" {
  service = "appengine.googleapis.com"
}

resource "google_project_service" "cloudresourcemanager" {
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "firestore" {
  service = "firestore.googleapis.com"
}

resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
}

resource "google_project_service" "iamcredentials" {
  service            = "iamcredentials.googleapis.com"
}

resource "google_project_service" "service_control" {
  service = "servicecontrol.googleapis.com"
}

resource "google_project_service" "service_management" {
  service = "servicemanagement.googleapis.com"
}

resource "google_project_service" "secret_manager" {
  service = "secretmanager.googleapis.com"
}
