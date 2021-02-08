module "iiif-prod" {
  source = "./cloudfront_distro"

  environment         = "prod"
  acm_certificate_arn = module.cert.arn

  origins    = local.origins["prod"]
  behaviours = local.behaviours
}

module "iiif-stage" {
  source = "./cloudfront_distro"

  environment         = "stage"
  acm_certificate_arn = module.cert.arn

  origins = local.origins["stage"]

  behaviours = local.stage_behaviours
}

module "iiif-test" {
  source = "./cloudfront_distro"

  environment         = "test"
  acm_certificate_arn = module.cert.arn

  origins    = local.origins["test"]
  behaviours = local.behaviours
}
