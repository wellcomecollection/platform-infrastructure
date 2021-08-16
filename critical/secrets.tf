locals {
  logging_secrets = {
    ES_USER         = "shared/logging/es_user"
    ES_PASS         = "shared/logging/es_pass"
    ES_HOST         = "shared/logging/es_host"
    ES_PORT         = "shared/logging/es_port"
    ES_HOST_PRIVATE = "shared/logging/es_host_private"
  }

  apm_secrets = {
    APM_SERVER_URL = "elasticsearch/logging/apm_server_url"
    APM_SECRET     = "elasticsearch/logging/apm_secret"
  }

  shared_secrets = merge(local.logging_secrets, local.apm_secrets)
}

module "storage_logging_secrets" {
  source = "./modules/secrets/distributed"

  providers = {
    aws = aws.storage
  }

  secrets = local.shared_secrets
}

module "catalogue_logging_secrets" {
  source = "./modules/secrets/distributed"

  providers = {
    aws = aws.catalogue
  }

  secrets = local.shared_secrets
}

module "experience_logging_secrets" {
  source = "./modules/secrets/distributed"

  providers = {
    aws = aws.experience
  }

  secrets = local.shared_secrets
}

module "workflow_logging_secrets" {
  source = "./modules/secrets/distributed"

  providers = {
    aws = aws.workflow
  }

  secrets = local.shared_secrets
}

module "digirati_logging_secrets" {
  source = "./modules/secrets/distributed"

  providers = {
    aws = aws.digirati
  }

  secrets = local.shared_secrets
}

module "identity_logging_secrets" {
  source = "./modules/secrets/distributed"

  providers = {
    aws = aws.identity
  }

  secrets = local.shared_secrets
}
