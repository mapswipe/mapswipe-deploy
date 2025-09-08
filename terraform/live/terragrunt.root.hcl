locals {
  env_name       = path_relative_to_include()
  secrets_config = jsondecode(read_tfvars_file("${get_terragrunt_dir()}/../secrets.auto.tfvars"))
}

remote_state {
  backend = "gcs"
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
  env_name       = local.env_name
  gcs_project_id = local.secrets_config.project_id_map[local.env_name]
  gcs_region     = "EU"
}
