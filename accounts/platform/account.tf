# Parent Platform account

module "aws_account" {
  source = "../modules/account/aws"

  # 4 hours
  max_session_duration_in_seconds = 4 * 60 * 60

  prefix = "platform"

  principals = [
    local.account_principals["platform"],
  ]

  infra_bucket_arn = "arn:aws:s3:::wellcomecollection-platform-infra"
}

module "account_federation" {
  source = "../modules/account/federated"

  saml_xml = data.aws_s3_bucket_object.account_federation_saml.body
  pgp_key  = data.template_file.pgp_key.rendered

  prefix = "azure_sso"
}

data "aws_s3_bucket_object" "account_federation_saml" {
  bucket = "wellcomecollection-platform-infra"
  key    = "platform-terraform-objects/saml.xml"
}
