locals {
  default_tags = {
    TerraformConfigurationURL = "https://github.com/wellcomecollection/platform-infrastructure/tree/main/costs_report/terraform"
    Department                = "Digital Platform"
    Division                  = "Culture and Society"
    Use                       = "Costs report"
    Environment               = "Production"
  }
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"
  }

  default_tags {
    tags = local.default_tags
  }
}
