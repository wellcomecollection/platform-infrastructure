module "wellcomecollection-prod" {
  source = "./cloudfront_distro"

  environment         = "prod"
  acm_certificate_arn = data.aws_acm_certificate.api_wc_org.arn
}

module "wellcomecollection-stage" {
  source = "./cloudfront_distro"

  environment         = "stage"
  acm_certificate_arn = data.aws_acm_certificate.api_wc_org.arn
}
