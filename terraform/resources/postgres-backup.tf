resource "google_storage_bucket" "db_backup_bucket_name" {
  name          = "mapswipe-postgres-backups-${var.env_name}"
  location      = var.gcs_region
  storage_class = "COLDLINE"

  uniform_bucket_level_access = true
}

resource "google_service_account" "db_backup_sa" {
  account_id   = "db-backup-sa-${var.env_name}"
  display_name = "DB Backup Service Account (pgBackRest) - ${var.env_name}"
}

resource "google_storage_bucket_iam_member" "db_backup_writer" {
  bucket = google_storage_bucket.db_backup_bucket_name.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.db_backup_sa.email}"
}

output "service_account_email" {
  value = google_service_account.db_backup_sa.email
}
