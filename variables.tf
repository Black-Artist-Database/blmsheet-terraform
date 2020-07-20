variable "project_services" {
  type = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "dns.googleapis.com",
    "run.googleapis.com",
    "compute.googleapis.com",
    "firestore.googleapis.com",
    "cloudscheduler.googleapis.com",
    "cloudbuild.googleapis.com",
    "vpcaccess.googleapis.com",
    "sheets.googleapis.com"
  ]
  description = "List of services to enable on the project."
}

variable "project" {
  type        = string
  description = "Name of project"
}

variable "region" {
  type        = string
  description = "Default region of project"
}

variable "registry" {
  description = "Container registry e.g eu.gcr.io or us.gcr.io"
  type        = string
}

variable "image_name" {
  description = "Name of the image to run on cloud run"
  type        = string
}

variable "image_version" {
  type        = string
  description = "Image version to deploy"
}

variable "domain" {
  type        = string
  description = "Your root domain without prefixes e.g example.com"
}

variable "sheet_id" {
  description = "Google Sheets ID of crowd-sourced list"
  type        = string
}

variable "tab_id" {
  description = "Literal name of tab from sheet"
  type        = string
}

variable "start_row" {
  description = "First entry in the sheet"
}

variable "collection" {
    default             = "entries"
}

variable "topic" {
    default             = "scrape"
}

variable "timezone" {
    default             = "Etc/UTC"
}

variable "redis_url" {
}

variable "owner" {
    default             = "jcox-dev"
}

variable "repo" {
    default             = "blmsheet"
}
