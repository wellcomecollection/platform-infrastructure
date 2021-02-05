module "wellcomecollection-prod" {
  source = "./wellcomecollection"

  environment         = "prod"
  acm_certificate_arn = data.aws_acm_certificate.api_wc_org.arn
}

module "wellcomecollection-stage" {
  source = "./wellcomecollection"

  environment         = "stage"
  acm_certificate_arn = data.aws_acm_certificate.api_wc_org.arn
}
