module "catalogue_slack_secrets" {
  source = "../../critical/modules/secrets/distributed"

  secrets = {
    noncritical_slack_webhook = "monitoring/critical_slack_webhook"
  }

  providers = {
    aws = aws.catalogue
  }
}

module "storage_slack_secrets" {
  source = "../../critical/modules/secrets/distributed"

  secrets = {
    noncritical_slack_webhook = "monitoring/critical_slack_webhook"
  }

  providers = {
    aws = aws.storage
  }
}

module "identity_slack_secrets" {
  source = "../../critical/modules/secrets/distributed"

  secrets = {
    noncritical_slack_webhook = "monitoring/critical_slack_webhook"
  }

  providers = {
    aws = aws.identity
  }
}
