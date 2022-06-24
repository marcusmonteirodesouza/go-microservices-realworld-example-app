variable "billing_account" {
  type        = string
  description = "The alphanumeric ID of the billing account this project belongs to."
}

variable "environment" {
  type        = string
  description = "The project's environment."
}

variable "folder_id" {
  type        = string
  description = "The numeric ID of the folder this project should be created under."
}

variable "project_id" {
  type        = string
  description = "The project ID."
}

variable "tfstate_bucket_location" {
  type        = string
  description = "The GCS location of the terraform state bucket."
}
