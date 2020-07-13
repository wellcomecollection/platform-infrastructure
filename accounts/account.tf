locals {
  sbt_releases_bucket_arn = "arn:aws:s3:::releases.mvn-repo.wellcomecollection.org"
}

# Parent Platform account

module "aws_account" {
  source = "./modules/account/aws"

  # 4 hours
  max_session_duration_in_seconds = 4 * 60 * 60

  prefix = "platform"

  principals = [
    local.aws_principal,
  ]

  infra_bucket_arn        = "arn:aws:s3:::wellcomecollection-platform-infra"
  sbt_releases_bucket_arn = local.sbt_releases_bucket_arn
}

module "account_federation" {
  source = "./modules/account/federated"

  saml_xml = data.aws_s3_bucket_object.account_federation_saml.body
  pgp_key  = data.template_file.pgp_key.rendered

  prefix = "azure_sso"
}

data "aws_s3_bucket_object" "account_federation_saml" {
  bucket = "wellcomecollection-platform-infra"
  key    = "platform-terraform-objects/saml.xml"
}

# Child Platform Accounts

module "catalogue_account" {
  source = "./modules/account/aws"

  providers = {
    aws = aws.catalogue
  }

  prefix = "catalogue"
  principals = [
    local.aws_principal
  ]

  infra_bucket_arn        = "arn:aws:s3:::wellcomecollection-catalogue-infra-delta"
  sbt_releases_bucket_arn = local.sbt_releases_bucket_arn
}

module "workflow_account" {
  source = "./modules/account/aws"

  providers = {
    aws = aws.workflow
  }

  prefix = "workflow"
  principals = [
    local.aws_principal
  ]

  infra_bucket_arn        = "arn:aws:s3:::wellcomecollection-workflow-infra"
  sbt_releases_bucket_arn = local.sbt_releases_bucket_arn
}

module "storage_account" {
  source = "./modules/account/aws"

  providers = {
    aws = aws.storage
  }

  prefix = "storage"
  principals = [
    local.aws_principal
  ]

  infra_bucket_arn        = "arn:aws:s3:::wellcomecollection-storage-infra"
  sbt_releases_bucket_arn = local.sbt_releases_bucket_arn
}

module "data_account" {
  source = "./modules/account/aws"

  providers = {
    aws = aws.data
  }

  prefix = "data"
  principals = [
    local.aws_principal
  ]

  infra_bucket_arn        = "arn:aws:s3:::wellcomecollection-datascience-infra"
  sbt_releases_bucket_arn = local.sbt_releases_bucket_arn
}

module "reporting_account" {
  source = "./modules/account/aws"

  providers = {
    aws = aws.reporting
  }

  prefix = "reporting"
  principals = [
    local.aws_principal
  ]

  infra_bucket_arn        = "arn:aws:s3:::wellcomecollection-reporting-infra"
  sbt_releases_bucket_arn = local.sbt_releases_bucket_arn
}

module "experience_account" {
  source = "./modules/account/aws"

  providers = {
    aws = aws.experience
  }

  prefix = "experience"

  principals = [
    local.aws_principal
  ]

  infra_bucket_arn        = "arn:aws:s3:::wellcomecollection-experience-infra"
  sbt_releases_bucket_arn = local.sbt_releases_bucket_arn
}

module "digitisation_account" {
  source = "./modules/account/aws"

  providers = {
    aws = aws.digitisation
  }

  prefix = "digitisation"
  principals = [
    local.aws_principal
  ]

  sbt_releases_bucket_arn = local.sbt_releases_bucket_arn
}

module "digirati_account" {
  source = "./modules/account/aws"

  providers = {
    aws = aws.digirati
  }

  prefix = "digirati"

  principals = [
    local.aws_principal
  ]

  sbt_releases_bucket_arn = local.sbt_releases_bucket_arn
}
