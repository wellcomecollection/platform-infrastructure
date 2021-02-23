module "cert" {
  source = "../modules/certificate"

  domain_name = "reporting.wellcomecollection.org"

  ttl = 60

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