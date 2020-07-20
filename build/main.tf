resource "google_cloudbuild_trigger" "push-trigger" {
    description          = "Push to GitHub master branch"
    disabled             = false
    provider             = google-beta
    filename             = "cloudbuild-multi-region.yaml"
    name                 = "build-from-master"
    project              = var.project
    github {
        owner            = var.owner
        name             = var.repo
        push {
            branch       = "^master$"
        }
    }
    substitutions  = {
      "_FUNCTION_NAME"   = "scrape-bandcamp-details"
      "_REGION1"         = "europe-west1"
      "_REGION2"         = "us-east1"
      "_REGION3"         = "us-west1"
      "_REGION4"         = "asia-northeast1"
      "_IMAGE_NAME"      = var.image_name
      "_SERVICE_NAME1"   = "${var.image_name}-europe-west1"
      "_SERVICE_NAME2"   = "${var.image_name}-us-east1"
      "_SERVICE_NAME3"   = "${var.image_name}-us-west1"
      "_SERVICE_NAME4"   = "${var.image_name}-asia-northeast1"
      "_TOPIC_NAME"      = var.topic
    }
}
