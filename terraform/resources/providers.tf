provider "google" {
  project               = var.gcs_project_id
  region                = var.gcs_region
  billing_project       = var.gcs_project_id
  user_project_override = true
}
