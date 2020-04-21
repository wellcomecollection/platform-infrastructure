module "storage_logging_secrets" {
  source = "./modules/secrets/logging"

  providers = {
    aws = aws.storage
  }
}