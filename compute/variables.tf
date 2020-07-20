variable "locations" {
  description = "Locations to run cloud run image in"
  type        = list
  default     = ["europe-west1", "us-east1", "us-west1", "asia-northeast1"]
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
  description = "Version of service"
  type        = string
}

variable "project" {
  description = "Project"
  type        = string
}

variable "service_account_email" {
  description = "Service account email to run containers under"
  type        = string
}

variable "static_ip_name" {
  description = "Name of the static IP resource"
  type        = string
}

variable "ssl_cert_name" {
  description = "Name of the managed SSL certificate resource"
  type        = string
}

variable "services" {
  description = "Google APIs and Services"
}

variable "vpc_link" {
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

variable "basic_auth_pass" {}

variable "collection" {
    default             = "entries"
}

variable "topic" {
}

variable "timezone" {
    default             = "Etc/UTC"
}

variable "redis_url" {
}
