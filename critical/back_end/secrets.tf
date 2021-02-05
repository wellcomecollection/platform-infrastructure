locals {
  logging_secrets = {
    ES_USER = "shared/logging/es_user"
    ES_PASS = "shared/logging/es_pass"
    ES_HOST = "shared/logging/es_host"
    ES_PORT = "shared/logging/es_port"
  }
}

module "storage_logging_secrets" {
  source = "./modules/secrets/distributed"

  providers = {
    aws = aws.storage
  }

  secrets = local.logging_secrets
}

module "catalogue_logging_secrets" {
  source = "./modules/secrets/distributed"

  providers = {
    aws = aws.catalogue
  }

  secrets = local.logging_secrets
}

module "experience_logging_secrets" {
  source = "./modules/secrets/distributed"

  providers = {
    aws = aws.experience
  }

  secrets = local.logging_secrets
}

module "workflow_logging_secrets" {
  source = "./modules/secrets/distributed"

  providers = {
    aws = aws.workflow
  }

  secrets = local.logging_secrets
}

module "digirati_logging_secrets" {
  source = "./modules/secrets/distributed"

  providers = {
    aws = aws.digirati
  }

  secrets = local.logging_secrets
}

module "identity_logging_secrets" {
  source = "./modules/secrets/distributed"

  providers = {
    aws = aws.identity
  }

  secrets = local.logging_secrets
}
