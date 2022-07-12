variable "location" {
  type        = string
  description = "The Profiles Service location."
}

variable "image" {
  type        = string
  description = "The Artifact Registry Profiles Service Docker image."
}

variable "users_service_base_url" {
  type        = string
  description = "The Users Service base URL."
}

variable "network" {
  type        = string
  description = "The network in which resources will be created in."
}
