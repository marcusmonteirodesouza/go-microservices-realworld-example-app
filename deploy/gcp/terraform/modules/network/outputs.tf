output "network" {
  value = google_compute_network.vpc_network.name
}

output "subnetwork" {
  value = google_compute_subnetwork.default.name
}
