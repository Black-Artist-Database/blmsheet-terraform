output "name" {
  value = google_compute_global_address.global-static-ip.name
}

output "static_ip" {
  value = google_compute_global_address.global-static-ip.address
}

output "vpc_link" {
  value = google_vpc_access_connector.default.self_link
}