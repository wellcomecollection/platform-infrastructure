locals {
  aws_region = "eu-west-1"

  account_ids = {
    catalogue  = "756629837203"
    reporting  = "269807742353"
    experience = "130871440101"
  }

  default_tags = {
    TerraformConfigurationURL = "https://github.com/wellcomecollection/platform-infrastructure/tree/main/critical"
  }
}
