locals {
  image = "${google_artifact_registry_repository.users_service.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.users_service.repository_id}/users-service"
}
