terraform {
  backend "gcs" {
    bucket = "infra12345"
    prefix = "terraform-gcp-infra/state"
    project = "devops-171"
    region = "us-central1-a"
  }
}