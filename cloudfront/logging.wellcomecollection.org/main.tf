module "kibana-logging" {
  source = "../modules/kibana"

  alias   = "logging.wellcomecollection.org"
  comment = "Kibana (logging)"

  origin_domain_name  = data.terraform_remote_state.infra_critical.outputs.logging_kibana_endpoint
  acm_certificate_arn = module.cert.arn
}
