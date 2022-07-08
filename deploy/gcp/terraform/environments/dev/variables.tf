variable "project_id" {
  type        = string
  description = "The project ID."
}

variable "region" {
  type        = string
  description = "The default GCP region for the created resources."
}

variable "firestore_location_id" {
  type        = string
  description = "The Firestore location ID."
}

variable "artifact_registry_location" {
  type        = string
  description = "The Artifact Registry location."
}

variable "users_service_image" {
  type        = string
  description = "The default GCP region for the created resources."
}
