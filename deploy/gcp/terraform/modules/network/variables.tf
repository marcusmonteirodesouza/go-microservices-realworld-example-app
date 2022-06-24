variable "project_id" {
  type        = string
  description = "The project ID."
}

variable "region" {
  type        = string
  description = "The default GCP region for the created resources."
}

variable "subnetwork_ip_cidr_range" {
  type        = string
  description = "The range of internal addresses that are owned by the created subnetwork."
}
