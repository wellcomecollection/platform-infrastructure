module "cert" {
  source = "../modules/certificate"

  domain_name = "api.wellcomecollection.org"

  subject_alternative_names = [
    "api-stage.wellcomecollection.org",
  ]

  ttl = 60

  providers = {
    aws     = aws.us_east_1
    aws.dns = aws.dns
  }
}
