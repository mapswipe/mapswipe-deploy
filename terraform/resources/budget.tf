resource "google_monitoring_notification_channel" "toggle_dev" {
  display_name = "Toggle dev"
  type         = "email"

  labels = {
    email_address = var.togglecorp_dev_email_address
  }
}


resource "google_billing_budget" "gcp_budget" {
  billing_account = var.gcs_billing_account_id

  display_name = "Monthly Budget [${var.env_name}]"

  budget_filter {
    projects = ["projects/${data.google_project.mapswipe.number}"]
  }

  amount {
    specified_amount {
      currency_code = "GBP" # £
      units         = var.budget_amount
    }
  }

  threshold_rules {
    spend_basis       = "CURRENT_SPEND"
    threshold_percent = 0.9
  }

  threshold_rules {
    spend_basis       = "CURRENT_SPEND"
    threshold_percent = 1.2
  }

  threshold_rules {
    spend_basis       = "CURRENT_SPEND"
    threshold_percent = 1.4
  }

  threshold_rules {
    spend_basis       = "CURRENT_SPEND"
    threshold_percent = 1.6
  }

  all_updates_rule {
    monitoring_notification_channels = [
      google_monitoring_notification_channel.toggle_dev.id,
    ]
    disable_default_iam_recipients = true
  }
}
