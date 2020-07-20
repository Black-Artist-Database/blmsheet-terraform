resource "google_cloud_scheduler_job" "clear-cache" {
    name                = "clear-cache"
    project             = var.project
    region              = "europe-west2"
    schedule            = "0 0 29 2 1"
    time_zone           = var.timezone

    http_target {
        headers         = {}
        http_method     = "POST"
        uri             = "${var.app_url}/api/clear"
    }
}


resource "google_cloud_scheduler_job" "scrape-bandcamp" {
    name                = "daily-scrape-bandcamp"
    project             = var.project
    region              = "europe-west2"
    schedule            = "0 */6 * * *"
    time_zone           = var.timezone

    http_target {
        headers         = {}
        http_method     = "POST"
        uri             = "${var.app_url}/cron/scrape-bandcamp?auth=${var.basic_auth_pass}"
    }
}


resource "google_cloud_scheduler_job" "remove-old" {
    name                = "remove-old-entries"
    project             = var.project
    region              = "europe-west2"
    schedule            = "0 */12 * * *"
    time_zone           = var.timezone

    http_target {
        headers         = {}
        http_method     = "POST"
        uri             = "${var.app_url}/cron/remove-old?auth=${var.basic_auth_pass}"
    }
}


resource "google_cloud_scheduler_job" "sync-sheet" {
    name                = "sync-sheet-to-firestore"
    project             = var.project
    region              = "europe-west2"
    schedule            = "0 */3 * * *"
    time_zone           = var.timezone

    http_target {
        headers         = {}
        http_method     = "POST"
        uri             = "${var.app_url}/cron/sync?auth=${var.basic_auth_pass}"
    }
}
