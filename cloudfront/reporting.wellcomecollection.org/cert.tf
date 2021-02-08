module "cert" {
  source = "../modules/certificate"

  domain_name = "reporting.wellcomecollection.org"

  ttl = 60

  providers = {
    aws     = aws.us_east_1
    aws.dns = aws.dns
  }
}
