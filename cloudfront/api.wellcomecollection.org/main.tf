locals {
  prod_domain  = "api.wellcomecollection.org"
  stage_domain = "api-stage.wellcomecollection.org"
}

module "wellcomecollection_prod" {
  source = "./cloudfront_distro"

  comment = "Collection APIs (prod)"
  aliases = [local.prod_domain]
  origin_domains = {
    catalogue = "catalogue.api-prod.wellcomecollection.org"
    content   = "content.api-prod.wellcomecollection.org"
    storage   = "storage.${local.prod_domain}"
    text      = "dds.wellcomecollection.digirati.io"
  }

  root_s3_domain = aws_s3_bucket.public_api.bucket_domain_name

  acm_certificate_arn = module.cert.arn

  cloudfront_logs_bucket = aws_s3_bucket.cloudfront_logs.id
}

module "wellcomecollection_stage" {
  source = "./cloudfront_distro"

  comment = "Collection APIs (stage)"
  aliases = [local.stage_domain]
  origin_domains = {
    catalogue = "catalogue.api-stage.wellcomecollection.org"
    content   = "content.api-stage.wellcomecollection.org"
    storage   = "storage.${local.stage_domain}"
    text      = "dds-stage.wellcomecollection.digirati.io"
  }

  root_s3_domain = aws_s3_bucket.public_api.bucket_domain_name

  acm_certificate_arn = module.cert.arn

  cloudfront_logs_bucket = aws_s3_bucket.cloudfront_logs.id
}
