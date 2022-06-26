output "url" {
  value = google_cloud_run_service.users_service.status[0].url
}
