locals {
  default_tags = {
    TerraformConfigurationURL = "https://github.com/wellcomecollection/platform-infrastructure/tree/master/assets"
  }
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.7"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-admin"
  }
}
