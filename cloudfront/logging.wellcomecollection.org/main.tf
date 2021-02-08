module "kibana-logging" {
  source = "../modules/kibana"

  alias   = "logging.wellcomecollection.org"
  comment = "Kibana (logging)"

  origin_domain_name  = "393eaa6b8f93443c851fc957cccdd5cb.eu-west-1.aws.found.io"
  acm_certificate_arn = module.cert.arn
}
