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

variable "gcs_billing_account_id" {
  description = "GCS billing account id"
  type        = string
  sensitive   = true
}

variable "budget_amount" {
  description = "Budget amount in GBP (£)"
  type        = number
}

variable "togglecorp_dev_email_address" {
  description = "Togglecorp dev email address"
  type        = string
}
