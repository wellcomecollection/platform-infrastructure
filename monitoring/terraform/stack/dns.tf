resource "aws_route53_record" "monitoring_wc_org" {
  provider = aws.dns

  zone_id = data.aws_route53_zone.dotorg.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_alb.alb.dns_name
    zone_id                = aws_alb.alb.zone_id
    evaluate_target_health = true
  }
}

data "aws_route53_zone" "dotorg" {
  provider = aws.dns
  name     = "wellcomecollection.org."
}
