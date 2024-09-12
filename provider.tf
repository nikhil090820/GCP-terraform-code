#provider
provider "google" {
  project = "devops-171"
  region  = "us-central1-a"
  # credentials = file("${var.service_account_key}")
}