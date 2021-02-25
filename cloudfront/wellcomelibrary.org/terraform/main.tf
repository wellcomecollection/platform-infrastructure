module "wellcomelibrary-prod" {
  source = "./cloudfront_distro"

  distro_alias = "wellcomelibrary.org"

  acm_certificate_arn = module.cert.arn

  origins    = local.prod_origins
  behaviours = local.prod_behaviours

  default_target_origin_id = "origin"
}

module "wellcomelibrary-stage" {
  source = "./cloudfront_distro"

  distro_alias = "stage.wellcomelibrary.org"

  acm_certificate_arn = module.cert.arn

  origins    = local.stage_origins
  behaviours = local.stage_behaviours

  default_target_origin_id = "origin"
}