locals {
  default_tags = {
    "Department"                = "Digital Platform"
    "Division"                  = "Wellcome Collection"
    "Environment"               = "Production"
    "TerraformConfigurationURL" = "https://github.com/wellcomecollection/platform-infrastructure/tree/main/accounts/digitisation"
    "Use"                       = "Digitisation account infrastructure"
  }
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::404315009621:role/digitisation-admin"
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  region = "eu-west-1"

  alias = "platform"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-admin"
  }

  default_tags {
    tags = local.default_tags
  }
}
