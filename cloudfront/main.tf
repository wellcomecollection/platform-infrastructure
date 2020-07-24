module "iiif-prod" {
  source = "./iiif"

  environment = "prod"
  acm_certificate_arn = local.iiif_acm_cert_arn
}

module "iiif-stage" {
  source = "./iiif"

  environment = "stage"
  acm_certificate_arn = local.iiif_acm_cert_arn
}

module "iiif-test" {
  source = "./iiif"

  environment = "test"
  acm_certificate_arn = local.iiif_acm_cert_arn
}

module "wellcomecollection-prod" {
  source = "./wellcomecollection"

  environment = "prod"
  acm_certificate_arn = data.aws_acm_certificate.api_wc_org.arn
}

module "wellcomecollection-stage" {
  source = "./wellcomecollection"

  environment = "stage"
  acm_certificate_arn = data.aws_acm_certificate.api_wc_org.arn
}

locals {
  iiif_acm_cert_arn = "arn:aws:acm:us-east-1:760097843905:certificate/1a749ce8-ebd3-4342-accb-37f692fc8e52"
}

data "aws_acm_certificate" "api_wc_org" {
  domain   = "api.wellcomecollection.org"
  statuses = ["ISSUED"]
  provider = aws.us_east_1
}