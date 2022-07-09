output "url" {
  value = google_cloud_run_service.profiles_service.status[0].url
}
