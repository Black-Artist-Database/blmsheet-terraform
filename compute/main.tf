resource "google_cloud_run_service" "multi-region-cloud-run" {
  name     = "${var.image_name}-${element(var.locations, count.index)}"
  count    = length(var.locations)
  location = element(var.locations, count.index)

  template {
    # metadata {
      # annotations = {
        # "run.googleapis.com/vpc-access-connector" = var.vpc_link
      # }
    # }
    spec {
      containers {
        image = "${var.registry}/${var.project}/${var.image_name}:${var.image_version}"
        env {
          name  = "SHEET_ID"
          value = var.sheet_id
        }
        env {
          name  = "TAB_ID"
          value = var.tab_id
        }
        env {
          name  = "START_ROW"
          value = var.start_row
        }
        env {
          name  = "DB_NAME"
          value = var.collection
        }
        env {
          name  = "REDIS_URL"
          value = var.redis_url
        }
        env {
          name  = "PROJECT_ID"
          value = var.project
        }
        env {
          name  = "SCRAPE_TOPIC"
          value = var.topic
        }
        env {
          name  = "AUTH_PASS"
          value = var.basic_auth_pass
        }
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512M"
          }
        }
      }
      service_account_name = var.service_account_email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [var.services]
}

data "google_iam_policy" "cloud-run-no-auth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "cloud-run-no-auth-policy" {
  count       = length(google_cloud_run_service.multi-region-cloud-run)
  location    = element(google_cloud_run_service.multi-region-cloud-run.*.location, count.index)
  project     = element(google_cloud_run_service.multi-region-cloud-run.*.project, count.index)
  service     = element(google_cloud_run_service.multi-region-cloud-run.*.name, count.index)
  policy_data = data.google_iam_policy.cloud-run-no-auth.policy_data
  depends_on  = [var.services]
}


// add a load balancer for redirecting HTTP -> HTTPS
resource "google_compute_url_map" "http-url-map" {
  name = "${var.image_name}-http-map"
  default_url_redirect {
    https_redirect = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query = false
  }
}

resource "google_compute_target_http_proxy" "default" {
  name    = "${var.image_name}-http-proxy"
  url_map = google_compute_url_map.http-url-map.id
}

resource "google_compute_global_forwarding_rule" "default" {
  name                = "${var.image_name}-http-content-rule"
  ip_address          = var.static_ip
  port_range          = "80"
  target              = google_compute_target_http_proxy.default.id
}

// handle the infrastructure that is not yet fully configurable or compatible with terraform
// The destroy code here isn't perfect since external references from destroy provisioners are deprecated.
// However, this code is just temporary until we can provision this with actual terraform resources,
// so for now this will do. :)
resource "null_resource" "load-balancer-and-serverless-negs" {
  provisioner "local-exec" {
    environment = {
      project        = var.project
      service_name   = var.image_name
      static_ip_name = var.static_ip_name
      ssl_cert_name  = var.ssl_cert_name
    }
    command = <<EOT
      gcloud auth activate-service-account terraform@$project.iam.gserviceaccount.com \
          --project=$project \
          --key-file=./.keys/terraform.json \
          --configuration=$project
      gcloud config configurations activate $project
      gcloud beta compute network-endpoint-groups create europe-west1-serverless-neg \
          --region=europe-west1 \
          --network-endpoint-type=SERVERLESS  \
          --cloud-run-service=$service_name-europe-west1
      gcloud beta compute network-endpoint-groups create us-east1-serverless-neg \
          --region=us-east1 \
          --network-endpoint-type=SERVERLESS  \
          --cloud-run-service=$service_name-us-east1
      gcloud beta compute network-endpoint-groups create us-west1-serverless-neg \
          --region=us-west1 \
          --network-endpoint-type=SERVERLESS  \
          --cloud-run-service=$service_name-us-west1
      gcloud beta compute network-endpoint-groups create asia-northeast1-serverless-neg \
          --region=asia-northeast1 \
          --network-endpoint-type=SERVERLESS  \
          --cloud-run-service=$service_name-asia-northeast1
      gcloud compute backend-services create $service_name-backend-service --global
      gcloud beta compute backend-services add-backend $service_name-backend-service \
        --global \
        --network-endpoint-group=europe-west1-serverless-neg \
        --network-endpoint-group-region=europe-west1
      gcloud beta compute backend-services add-backend $service_name-backend-service \
        --global \
        --network-endpoint-group=us-east1-serverless-neg \
        --network-endpoint-group-region=us-east1
      gcloud beta compute backend-services add-backend $service_name-backend-service \
        --global \
        --network-endpoint-group=us-west1-serverless-neg \
        --network-endpoint-group-region=us-west1
      gcloud beta compute backend-services add-backend $service_name-backend-service \
        --global \
        --network-endpoint-group=asia-northeast1-serverless-neg \
        --network-endpoint-group-region=asia-northeast1
      gcloud compute url-maps create $service_name-url-map --default-service $service_name-backend-service
      gcloud compute target-https-proxies create $service_name-https-proxy \
          --ssl-certificates=$ssl_cert_name \
          --url-map=$service_name-url-map
      gcloud compute forwarding-rules create $service_name-https-content-rule \
          --address=$static_ip_name \
          --target-https-proxy=$service_name-https-proxy \
          --global \
          --ports=443
      EOT
  }

  provisioner "local-exec" {
    when = destroy
    environment = {
      project      = var.project
      service_name = var.image_name
    }
    command = <<EOT
      gcloud auth activate-service-account terraform@$project.iam.gserviceaccount.com \
        --project=$project \
        --key-file=./.keys/terraform.json \
        --configuration=$project
      gcloud config configurations activate $project
      gcloud compute forwarding-rules delete $service_name-https-content-rule --global --quiet
      gcloud compute target-https-proxies delete $service_name-https-proxy --quiet
      gcloud beta compute backend-services remove-backend $service_name-backend-service \
        --global \
        --quiet \
        --network-endpoint-group=europe-west1-serverless-neg \
        --network-endpoint-group-region=europe-west1
      gcloud beta compute backend-services remove-backend $service_name-backend-service \
        --global \
        --quiet \
        --network-endpoint-group=us-east1-serverless-neg \
        --network-endpoint-group-region=us-east1
      gcloud beta compute backend-services remove-backend $service_name-backend-service \
        --global \
        --quiet \
        --network-endpoint-group=us-west1-serverless-neg \
        --network-endpoint-group-region=us-west1
      gcloud beta compute backend-services remove-backend $service_name-backend-service \
        --global \
        --quiet \
        --network-endpoint-group=asia-northeast1-serverless-neg \
        --network-endpoint-group-region=asia-northeast1
      gcloud compute url-maps delete $service_name-url-map --quiet
      gcloud compute backend-services delete $service_name-backend-service --global --quiet
      gcloud beta compute network-endpoint-groups delete europe-west1-serverless-neg --region=europe-west1 --quiet
      gcloud beta compute network-endpoint-groups delete us-east1-serverless-neg --region=us-east1 --quiet
      gcloud beta compute network-endpoint-groups delete us-west1-serverless-neg --region=us-west1 --quiet
      gcloud beta compute network-endpoint-groups delete asia-northeast1-serverless-neg --region=asia-northeast1 --quiet
      EOT
  }

  depends_on = [
    var.services,
    google_cloud_run_service.multi-region-cloud-run.0,
    google_cloud_run_service.multi-region-cloud-run.1,
    google_cloud_run_service.multi-region-cloud-run.2,
    google_cloud_run_service.multi-region-cloud-run.3,
  ]
}
