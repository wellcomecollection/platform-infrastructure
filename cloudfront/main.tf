module "iiif-prod" {
  source = "./iiif"

  environment = "prod"
  acm_certificate_arn = local.acm_cert_arn
}

module "iiif-stage" {
  source = "./iiif"

  environment = "stage"
  acm_certificate_arn = local.acm_cert_arn
}

module "iiif-test" {
  source = "./iiif"

  environment = "test"
  acm_certificate_arn = local.acm_cert_arn
}

locals {
  acm_cert_arn = "arn:aws:acm:us-east-1:760097843905:certificate/1a749ce8-ebd3-4342-accb-37f692fc8e52"
}