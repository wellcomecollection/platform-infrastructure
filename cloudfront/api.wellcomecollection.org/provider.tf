locals {
  default_tags = {
    Managed                   = "terraform"
    TerraformConfigurationURL = "https://github.com/wellcomecollection/platform-infrastructure/tree/main/cloudfront/api.wellcomecollection.org"
  }
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-admin"
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias = "us_east_1"

  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  region = "eu-west-1"
  alias  = "dns"

  assume_role {
    role_arn = "arn:aws:iam::267269328833:role/wellcomecollection-assume_role_hosted_zone_update"
  }

  default_tags {
    tags = local.default_tags
  }
}
