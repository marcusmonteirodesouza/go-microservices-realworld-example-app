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

output "gcr_pubsub_topic_id" {
  description = "The id Pub/Sub topic created for publishing Artifact Registry events."
  value       = google_pubsub_topic.gcr.id
}

output "github_repository_dispatch_sa_email" {
  description = "The email address of the Google Cloud service account to use as the runtime service account for the RepositoryDispatch function."
  value       = google_service_account.github_repository_dispatch.email
}

output "github_repository_dispatch_personal_access_token_secret_name" {
  description = "The name of the Github Personal Access Token secret."
  value       = google_secret_manager_secret.github_repository_dispatch_personal_access_token.name
}
