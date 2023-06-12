resource "aws_route53_record" "monitoring_wc_org" {
  provider = aws.dns

  zone_id = data.aws_route53_zone.dotorg.zone_id
  name    = var.domain
  type    = "CNAME"
  ttl     = 300

  records = [aws_alb.alb.dns_name]
}

data "aws_route53_zone" "dotorg" {
  provider = aws.dns
  name     = "wellcomecollection.org."
}
