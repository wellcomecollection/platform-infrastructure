module "storage_logging_secrets" {
  source = "./modules/secrets/distributed"

  providers = {
    aws = aws.storage
  }

  secrets = {
    es_user = "shared/logging/es_user"
    es_pass = "shared/logging/es_pass"
    es_host = "shared/logging/es_host"
    es_port = "shared/logging/es_port"
  }
}