// TODO: These are set manually from values in Azure
// We could provision the app using an Azure terraform provider
// and hence automatically retrieve these values

data "aws_ssm_parameter" "logging_client_id" {
  name = "/logging/config/azure/client_id"
}

data "aws_ssm_parameter" "logging_tenant_id" {
  name = "/logging/config/azure/tenant_id"
}

locals {
  client_id = data.aws_ssm_parameter.logging_client_id.value
  tenant_id = data.aws_ssm_parameter.logging_tenant_id.value

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
