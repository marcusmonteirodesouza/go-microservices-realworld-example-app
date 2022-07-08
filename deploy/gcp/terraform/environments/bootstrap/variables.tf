variable "billing_account" {
  type        = string
  description = "The alphanumeric ID of the billing account this project belongs to."
}

variable "folder_id" {
  type        = string
  description = "The numeric ID of the folder this project should be created under."
}

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
