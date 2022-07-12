output "name" {
  value = google_cloud_run_service.users_service.name
}

output "url" {
  value = "http://${module.external_http_lb.ip_address}"
}
