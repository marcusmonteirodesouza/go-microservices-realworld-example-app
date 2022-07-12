variable "location" {
  type        = string
  description = "The Users Service location."
}

variable "image" {
  type        = string
  description = "The Artifact Registry Users Service Docker image."
}

variable "jwt_seconds_to_expire" {
  default     = 86400
  description = "The number of seconds a created JWT is valid for."
}
