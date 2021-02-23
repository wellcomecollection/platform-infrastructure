locals {
  domain_name = "${var.hostname}.${var.subdomain}"
  zone_id = data.aws_route53_zone.hostname_zone.id
}