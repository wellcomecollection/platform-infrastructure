provider "aws" {
  region  = "eu-west-1"
  version = "~> 2.7"

  assume_role {
    role_arn = "arn:aws:iam::404315009621:role/digitisation-admin"
  }
}

locals {
  default_tags = {
    TerraformConfigurationURL = "https://github.com/wellcomecollection/platform-infrastructure/tree/master/digitisation_infra"
  }
}
