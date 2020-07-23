provider "google" {
  version     = "~> 3.29.0"
  credentials = file("./.keys/terraform.json")
  project     = var.project
  region      = var.region
}

provider "google-beta" {
  version     = "~> 3.29.0"
  credentials = file("./.keys/terraform.json")
  project     = var.project
  region      = var.region
}

resource "google_project_service" "service" {
  count                      = length(var.project_services)
  project                    = var.project
  service                    = element(var.project_services, count.index)
  disable_on_destroy         = false
  disable_dependent_services = false
}

provider "null" {
  version = "~> 2.1.2"
}

provider "random" {
  version = "~> 2.3"
}

resource "random_password" "auth" {
  length = 16
  special = true
  override_special = "_%@"
}

module "network" {
  source   = "./network"
  services = google_project_service.service
  project  = var.project
  region   = var.region
}

module "ssl" {
  source   = "./ssl"
  domain   = var.domain
  services = google_project_service.service
}

module "dns" {
  source    = "./dns"
  static_ip = module.network.static_ip
  domain    = var.domain
  services  = google_project_service.service
}

module "service-accounts" {
  source   = "./service-accounts"
  services = google_project_service.service
}

module "firestore" {
  source     = "./firestore"
  services   = google_project_service.service
  collection = var.collection
  project    = var.project
}

module "pubsub" {
  source     = "./pubsub"
  services   = google_project_service.service
  topic      = var.topic
}

module "compute" {
  source                = "./compute"
  image_name            = var.image_name
  image_version         = var.image_version
  registry              = var.registry
  project               = var.project
  services              = google_project_service.service
  service_account_email = module.service-accounts.default_account
  static_ip             = module.network.static_ip
  static_ip_name        = module.network.name
  ssl_cert_name         = module.ssl.name
  vpc_link              = module.network.vpc_link
  sheet_id              = var.sheet_id
  tab_id                = var.tab_id
  start_row             = var.start_row
  topic                 = var.topic
  basic_auth_pass       = random_password.auth.result
  redis_url             = var.redis_url
  collection            = var.collection
}

module "scheduler" {
  source          = "./scheduler"
  services        = google_project_service.service
  project         = var.project
  region          = var.region
  timezone        = var.timezone
  app_url         = module.compute.app_url
  basic_auth_pass = random_password.auth.result
}

module "build" {
  source          = "./build"
  services        = google_project_service.service
  project         = var.project
  topic           = var.topic
  image_name      = var.image_name
  owner           = var.owner
  repo            = var.repo
}