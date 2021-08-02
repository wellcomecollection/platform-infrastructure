locals {
  secrets_to_copy = {
    noncritical_slack_webhook = "monitoring/critical_slack_webhook"
  }
}

module "shared_secrets" {
  source = "../../../../critical/modules/secrets/distributed"

  secrets = var.copy_secrets ? local.secrets_to_copy : {}
}
