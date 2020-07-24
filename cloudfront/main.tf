module "iiif-prod" {
  source = "./iiif"

  environment = "prod"
  acm_certificate_arn = data.aws_acm_certificate.iiif_wc_org.arn
}

module "iiif-stage" {
  source = "./iiif"

  environment = "stage"
  acm_certificate_arn = data.aws_acm_certificate.iiif_wc_org.arn
}

module "iiif-test" {
  source = "./iiif"

  environment = "test"
  acm_certificate_arn = data.aws_acm_certificate.iiif_wc_org.arn
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

module "kibana-logging" {
  source = "./kibana"

  alias   = "logging.wellcomecollection.org"
  comment = "Kibana (logging)"

  origin_domain_name  = "393eaa6b8f93443c851fc957cccdd5cb.eu-west-1.aws.found.io"
  acm_certificate_arn = data.aws_acm_certificate.logging_wc_org.arn
}

module "kibana-reporting" {
  source = "./kibana"

  alias   = "reporting.wellcomecollection.org"
  comment = "Kibana (reporting)"

  origin_domain_name  = "c783b93d8b0b4b11900b5793cb2a1865.eu-west-1.aws.found.io"
  acm_certificate_arn = data.aws_acm_certificate.reporting_wc_org.arn
}

module "productboard-wellcomecollection" {
  source = "./productboard"

  alias   = "roadmap.wellcomecollection.org"
  comment = "productboard (roadmap)"

  acm_certificate_arn = data.aws_acm_certificate.raodmap_wc_org.arn
}