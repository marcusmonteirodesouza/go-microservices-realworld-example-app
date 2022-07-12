output "name" {
  value = google_compute_network.default.name
}

output "lb_subnet" {
  value = google_compute_subnetwork.lb.name
}

output "proxy_only_subnet" {
  value = google_compute_subnetwork.proxy_only.name
}
