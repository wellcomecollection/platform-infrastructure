module "iiif-prod" {
  source = "./cloudfront_distro"

  environment         = "prod"
  acm_certificate_arn = module.cert.arn

  origins    = local.prod_origins
  behaviours = local.prod_behaviours

  default_target_origin_id = "iiif"

  providers = {
    aws.dns = aws.dns
  }
}

module "iiif-stage" {
  source = "./cloudfront_distro"

  environment         = "stage"
  acm_certificate_arn = module.cert.arn

  origins    = local.stage_origins
  behaviours = local.stage_behaviours

  default_target_origin_id = "iiif"

  providers = {
    aws.dns = aws.dns
  }
}

module "iiif-test" {
  source = "./cloudfront_distro"

  environment         = "test"
  acm_certificate_arn = module.cert.arn

  origins    = local.test_origins
  behaviours = local.test_behaviours

  default_target_origin_id = "iiif"

  providers = {
    aws.dns = aws.dns
  }
}
