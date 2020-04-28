# Distributed secrets

This module synchronises secrets from the platform account into client accounts as required.

This is useful where it would be dangerous for all client accounts to rely on access to a single resource in the platform account.

## Usage

This will create the secrets named in the `secrets` block in the specified provider account.

```
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
```