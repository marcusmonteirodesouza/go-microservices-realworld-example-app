variable "project_id" {
  type        = string
  description = "The project ID."
}

variable "region" {
  type        = string
  description = "The default GCP region for the created resources."
}

variable "jwt_seconds_to_expire" {
  default     = 86400
  description = "The number of seconds a created JWT is valid for."
}
