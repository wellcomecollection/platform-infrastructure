locals {
  prod_domain  = "api.wellcomecollection.org"
  stage_domain = "api-stage.wellcomecollection.org"
  default_tags = {
    Managed                   = "terraform"
    TerraformConfigurationURL = "https://github.com/wellcomecollection/platform-infrastructure/tree/main/cloudfront/api.wellcomecollection.org"
  }
}

module "wellcomecollection_prod" {
  source = "./cloudfront_distro"

  comment = "Collection APIs (prod)"
  aliases = [local.prod_domain]
  origin_domains = {
    catalogue = "catalogue.api-prod.wellcomecollection.org"
    storage   = "storage.${local.prod_domain}"
    text      = "dds.wellcomecollection.digirati.io"
  }

  root_s3_domain = aws_s3_bucket.public_api.bucket_domain_name

  acm_certificate_arn = module.cert.arn

  tags = local.default_tags
}

module "wellcomecollection_stage" {
  source = "./cloudfront_distro"

  comment = "Collection APIs (stage)"
  aliases = [local.stage_domain]
  origin_domains = {
    catalogue = "catalogue.api-stage.wellcomecollection.org"
    storage   = "storage.${local.stage_domain}"
    text      = "dds-stage.wellcomecollection.digirati.io"
  }

  root_s3_domain = aws_s3_bucket.public_api.bucket_domain_name

  acm_certificate_arn = module.cert.arn

  tags = local.default_tags
}
