module "cert" {
  source = "../modules/certificate"

  domain_name = "logging.wellcomecollection.org"

  subject_alternative_names = [
    "*.logging.wellcomecollection.org"
  ]

  ttl = 30

  zone_id = data.aws_route53_zone.zone.id

  providers = {
    aws     = aws.us_east_1
    aws.dns = aws.dns
  }
}

data "aws_route53_zone" "zone" {
  provider = aws.dns

  name = "wellcomecollection.org."
}