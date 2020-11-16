data "aws_route53_zone" "weco_zone" {
  provider = aws.dns
  name     = "wellcomecollection.org."
}

# Third-party services
resource "aws_route53_record" "docs" {
  zone_id = data.aws_route53_zone.weco_zone.id
  name    = "docs.wellcomecollection.org"
  type    = "CNAME"
  records = ["hosting.gitbook.com"]
  ttl     = "300"

  provider = aws.dns
}

resource "aws_route53_record" "rank" {
  zone_id = data.aws_route53_zone.weco_zone.id
  name    = "rank.wellcomecollection.org"
  type    = "CNAME"
  records = ["cname.vercel-dns.com"]
  ttl     = "300"

  provider = aws.dns
}

# See https://help.shopify.com/en/manual/online-store/os/domains/add-a-domain/using-existing-domains/connecting-domains#set-up-your-existing-domain-to-connect-to-shopify

resource "aws_route53_record" "shop" {
  zone_id = data.aws_route53_zone.weco_zone.id
  name    = "shop.${data.aws_route53_zone.weco_zone.name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["shops.myshopify.com"]

  provider = aws.dns
}

# Redirects
module "www" {
  source  = "./modules/redirect"
  from    = "www.wellcomecollection.org"
  to      = "wellcomecollection.org"
  zone_id = data.aws_route53_zone.weco_zone.id

  providers = {
    aws.dns = aws.dns
  }
}

resource "aws_route53_zone" "identity" {
  name = "identity.${data.aws_route53_zone.weco_zone.name}"
}

resource "aws_route53_record" "identity-ns" {
  zone_id = data.aws_route53_zone.weco_zone.id
  name    = "identity.${data.aws_route53_zone.weco_zone.name}"
  type    = "NS"
  ttl     = "300"
  records = local.temp_ns_records_identity

  provider = aws.dns
}

locals {
  temp_ns_records_identity = [
    "ns-1200.awsdns-22.org",
    "ns-1588.awsdns-06.co.uk",
    "ns-344.awsdns-43.com",
    "ns-599.awsdns-10.net",
  ]
}