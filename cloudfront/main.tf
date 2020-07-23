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
  acm_cert_arn = "arn:aws:acm:us-east-1:760097843905:certificate/04bb4447-b501-453a-804e-411d3f660a74"
}