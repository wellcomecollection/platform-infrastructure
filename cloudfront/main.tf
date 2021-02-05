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

module "productboard-wellcomecollection" {
  source = "./productboard"

  alias   = "roadmap.wellcomecollection.org"
  comment = "productboard (roadmap)"

  acm_certificate_arn = data.aws_acm_certificate.raodmap_wc_org.arn
}