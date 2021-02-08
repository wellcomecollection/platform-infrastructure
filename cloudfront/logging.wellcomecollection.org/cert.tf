module "cert" {
  source = "../modules/certificate"

  domain_name = "logging.wellcomecollection.org"

  subject_alternative_names = [
    "*.logging.wellcomecollection.org"
  ]

  ttl = 30

  providers = {
    aws     = aws.us_east_1
    aws.dns = aws.dns
  }
}
