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