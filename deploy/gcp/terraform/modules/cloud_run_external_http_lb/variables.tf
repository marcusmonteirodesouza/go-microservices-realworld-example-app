variable "network" {
  type        = string
  description = "The network into which the resources will be created in."
}

variable "cloud_run_service" {
  type        = string
  description = "The name of the Cloud Run service."
}
