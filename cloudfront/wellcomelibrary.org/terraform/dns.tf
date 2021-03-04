resource "aws_route53_record" "prod" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "wellcomelibrary.org"
  type    = "A"
  records = ["195.143.129.236"]
  ttl     = "300"

  provider = aws.dns
}

resource "aws_route53_record" "origin" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "origin.wellcomelibrary.org"
  type    = "A"
  records = ["195.143.129.236"]
  ttl     = "300"

  provider = aws.dns
}

resource "aws_route53_record" "stage" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "stage.wellcomelibrary.org"
  type    = "CNAME"
  records = [module.wellcomelibrary-stage.distro_domain_name]
  ttl     = "300"

  provider = aws.dns
}