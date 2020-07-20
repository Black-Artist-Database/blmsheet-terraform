resource "google_compute_global_address" "global-static-ip" {
  name       = "global-static-ip"
  depends_on = [var.services]
}

resource "google_vpc_access_connector" "default" {
    ip_cidr_range       = "10.8.0.0/28"
    max_throughput      = 300
    min_throughput      = 200
    name                = "vpc-connector-1"
    network             = "default"
    region              = var.region
    provider            = google-beta
}
