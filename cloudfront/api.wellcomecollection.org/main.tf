locals {
  prod_domain  = "api.wellcomecollection.org"
  stage_domain = "api-stage.wellcomecollection.org"
}

module "wellcomecollection-prod" {
  source = "./cloudfront_distro"

  comment = "Collection APIs (prod)"
  aliases = [local.prod_domain]
  origin_domains = {
    catalogue = "catalogue.api-prod.wellcomecollection.org"
    stacks    = "stacks.${local.prod_domain}"
    storage   = "storage.${local.prod_domain}"
    text      = "dds.wellcomecollection.digirati.io"
  }

  acm_certificate_arn = module.cert.arn
}

module "wellcomecollection-stage" {
  source = "./cloudfront_distro"

  comment = "Collection APIs (stage)"
  aliases = [local.stage_domain]
  origin_domains = {
    catalogue = "catalogue.api-stage-delta.wellcomecollection.org"
    stacks    = "stacks.${local.stage_domain}"
    storage   = "storage.${local.stage_domain}"
    text      = "dds-stage.wellcomecollection.digirati.io"
  }

  acm_certificate_arn = module.cert.arn
}
