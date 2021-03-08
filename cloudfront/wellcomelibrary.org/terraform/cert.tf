module "cert" {
  source = "../../modules/certificate"

  domain_name = "wellcomelibrary.org"

  zone_id = data.aws_route53_zone.zone.id

  providers = {
    aws     = aws.us_east_1
    aws.dns = aws.dns
  }

  subject_alternative_names = ["*.wellcomelibrary.org"]
}

module "cert-stage" {
  source = "../../modules/certificate"

  domain_name = "stage.wellcomelibrary.org"

  zone_id = data.aws_route53_zone.zone.id

  providers = {
    aws     = aws.us_east_1
    aws.dns = aws.dns
  }

  subject_alternative_names = ["*.stage.wellcomelibrary.org", "*.wellcomelibrary.org", "wellcomelibrary.org"]
}

data "aws_route53_zone" "zone" {
  provider = aws.dns

  name = "wellcomelibrary.org."
}