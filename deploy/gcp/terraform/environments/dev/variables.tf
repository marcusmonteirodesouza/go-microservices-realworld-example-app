variable "project_id" {
  type        = string
  description = "The project ID."
}

variable "region" {
  type        = string
  description = "The default GCP region for the created resources."
}

variable "artifact_registry_location" {
  type        = string
  description = "The Artifact Registry location."
}

variable "lb_ip_cidr_range" {
  type        = string
  description = "The IP CIDR range reserved for HTTP(S) Load Balancers."
}

variable "proxy_only_ip_cidr_range" {
  type        = string
  description = "The IP CIDR range reserved for Regional Managed Proxies."
}

variable "users_service_image" {
  type        = string
  description = "The Artifact Registry Users Service Docker image."
}

variable "profiles_service_image" {
  type        = string
  description = "The Artifact Registry Profiles Service Docker image."
}
