output "app_url" {
    value = google_cloud_run_service.multi-region-cloud-run.0.status[0].url
}