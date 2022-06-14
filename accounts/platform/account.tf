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

  saml_xml = data.aws_s3_object.account_federation_saml.body
  pgp_key  = file("${path.module}/wellcomedigitalplatform.pub")

  prefix = "azure_sso"
}

# This is the SAML metadata that enables us to log in to AWS using Azure AD
# and SSO.  It is given to us by D&T, and can also be managed in the
# "Identity Providers" pane of the IAM console [1].
#
# You can upload a new SAML file to the bucket like so:
#
#       AWS_PROFILE=platform-dev aws s3 cp \
#         --content-type 'text/xml' \
#         /file/from/d_and_t.xml \
#         s3://wellcomecollection-platform-infra/platform-terraform-objects/saml.xml*/
#
# The Content-Type header is significant here: the `aws_s3_object`
# data source won't fetch the Body of the object [2].  This will cause the
# following somewhat non-obvious error:
#
#       Error: Missing required argument
#
#         with module.account_federation.aws_iam_saml_provider.saml_provider,
#         on ../modules/account/federated/main.tf line 13, in resource "aws_iam_saml_provider" "saml_provider":
#         13:   saml_metadata_document = var.saml_xml
#
#       The argument "saml_metadata_document" is required, but no definition was found.
#
# [1]: https://us-east-1.console.aws.amazon.com/iamv2/home?region=us-east-1#/identity_providers
# [2]: https://registry.terraform.io/providers/hashicorp%20%20/aws/latest/docs/data-sources/s3_object
#
data "aws_s3_object" "account_federation_saml" {
  bucket = "wellcomecollection-platform-infra"
  key    = "platform-terraform-objects/saml.xml"
}
