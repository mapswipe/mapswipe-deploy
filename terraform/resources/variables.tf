variable "env_name" {
  description = "Mapswipe environment name"
  type        = string
}

# GCS
variable "gcs_project_id" {
  description = "GCS project id"
  type        = string
  sensitive   = true
}

variable "gcs_region" {
  description = "GCS region"
  type        = string
}
