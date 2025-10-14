locals {
  env_name       = path_relative_to_include()
  secrets_config = jsondecode(read_tfvars_file("${get_terragrunt_dir()}/../secrets.auto.tfvars"))
}

remote_state {
  disable_init = tobool(get_env("DISABLE_INIT", "false")) # Used for CI lint
  backend      = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    project  = local.secrets_config.project_id_map[local.env_name]
    bucket   = "mapswipe-tf-${local.env_name}"
    prefix   = "terraform/${local.env_name}"
    location = "EU"
  }
}

inputs = {
  env_name                     = local.env_name
  gcs_billing_account_id       = local.secrets_config.gcs_billing_account_id
  gcs_project_id               = local.secrets_config.project_id_map[local.env_name]
  gcs_region                   = "EU"
  togglecorp_dev_email_address = local.secrets_config.togglecorp_dev_email_address
}
