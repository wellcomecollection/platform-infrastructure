locals {
  subdomain_cname_records = {
    "docs" = "hosting.gitbook.com"
  }
}

resource "aws_route53_record" "subdomains" {
  for_each = local.subdomain_cname_records

  name    = "${each.key}.wellcomecollection.org"
  records = [each.value]

  zone_id = data.aws_route53_zone.weco_zone.id
  type    = "CNAME"
  ttl     = 300

  provider = aws.dns
}

moved {
  from = aws_route53_record.docs
  to   = aws_route53_record.subdomains["docs"]
}

# Third-party services

// This adds a CNAME record for our Chromatic instance of Storybook.
// It will be up to date with what's in the main branch.
resource "aws_route53_record" "cardigan" {
  zone_id = data.aws_route53_zone.weco_zone.id
  name    = "cardigan.wellcomecollection.org"
  type    = "CNAME"
  records = ["domains.chromatic.com"]
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

// This adds a CNAME record for Atlassion Statuspage (https://wellcomecollection.statuspage.io/)
resource "aws_route53_record" "status" {
  zone_id = data.aws_route53_zone.weco_zone.id
  name    = "status.wellcomecollection.org"
  type    = "CNAME"
  records = ["qyhn8w55666p.stspg-customer.com"]
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
  source  = "../../modules/redirect"
  from    = "www.wellcomecollection.org"
  to      = "wellcomecollection.org"
  zone_id = data.aws_route53_zone.weco_zone.id

  providers = {
    aws.dns = aws.dns
  }
}
