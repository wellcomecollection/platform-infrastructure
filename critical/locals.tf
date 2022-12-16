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
    catalogue  = data.aws_caller_identity.catalogue.account_id
    digirati  = data.aws_caller_identity.digirati.account_id
    experience = data.aws_caller_identity.experience.account_id
    identity = data.aws_caller_identity.identity.account_id
    reporting = data.aws_caller_identity.reporting.account_id
    storage = data.aws_caller_identity.storage.account_id
    workflow = data.aws_caller_identity.workflow.account_id
  }

  default_tags = {
    TerraformConfigurationURL = "https://github.com/wellcomecollection/platform-infrastructure/tree/main/critical"
  }
}

data "aws_caller_identity" "catalogue" {
  provider = aws.catalogue
}
data "aws_caller_identity" "digirati" {
  provider = aws.digirati
}
data "aws_caller_identity" "experience" {
  provider = aws.experience
}
data "aws_caller_identity" "identity" {
  provider = aws.identity
}
data "aws_caller_identity" "reporting" {
  provider = aws.reporting
}
data "aws_caller_identity" "storage" {
  provider = aws.storage
}
data "aws_caller_identity" "workflow" {
  provider = aws.workflow
}
