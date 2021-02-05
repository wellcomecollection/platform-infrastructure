module "wellcomecollection-prod" {
  source = "./cloudfront_distro"

  environment         = "prod"
  acm_certificate_arn = module.cert.arn
}

module "wellcomecollection-stage" {
  source = "./cloudfront_distro"

  environment         = "stage"
  acm_certificate_arn = module.cert.arn
}
