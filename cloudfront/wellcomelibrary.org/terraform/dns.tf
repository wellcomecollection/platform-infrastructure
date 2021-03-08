resource "aws_route53_record" "prod-internal" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "wellcomelibrary.org"
  type    = "A"
  records = ["195.143.129.236"]
  ttl     = "60"

  weighted_routing_policy {
    weight = 0
  }

  set_identifier = "internal"

  provider = aws.dns
}

resource "aws_route53_record" "prod-cloudfront" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "wellcomelibrary.org"
  type    = "A"

  weighted_routing_policy {
    weight = 50
  }

  alias {
    name                   = "d2cksn8op995w4.cloudfront.net"
    evaluate_target_health = false
    zone_id                = "Z2FDTNDATAQYW2"
  }

  set_identifier = "cloudfront"

  provider = aws.dns
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "www.wellcomelibrary.org"
  type    = "CNAME"
  records = ["wellcomelibrary.org"]
  ttl     = "60"

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

resource "aws_route53_record" "stage-www" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "www.stage.wellcomelibrary.org"
  type    = "CNAME"
  records = [module.wellcomelibrary-stage.distro_domain_name]
  ttl     = "60"

  provider = aws.dns
}