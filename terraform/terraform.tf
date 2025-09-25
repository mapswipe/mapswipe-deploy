terraform {
  required_version = ">= 1.9.0"

  backend "gcs" {
    bucket = "tf-state"
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}
