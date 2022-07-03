output "tfstate_bucket" {
  value = google_storage_bucket.tfstate.name
}

output "github_deployer_sa_email" {
  description = "Github Deployer Service Account email."
  value       = google_service_account.github_deployer.email
}

output "github_oidc_provider" {
  description = "Workload Identity Provider name."
  value       = module.github_oidc.provider_name
}
