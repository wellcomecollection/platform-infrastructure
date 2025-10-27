locals {
  # CNAME records for third party services.
  subdomain_cname_records = {

    # This is for our Chromatic instance of Storybook.
    # It will be up to date with what's in the main branch.
    "cardigan.wellcomecollection.org" = "domains.chromatic.com"

    # This is our GitBook instance.
    "docs.wellcomecollection.org" = "hosting.gitbook.com"

    # This is the front-end to rank, our tool for testing API search quality.
    # See https://github.com/wellcomecollection/catalogue-api/tree/main/rank
    "rank.wellcomecollection.org" = "cname.vercel-dns.com"

    # See https://help.shopify.com/en/manual/online-store/os/domains/add-a-domain/using-existing-domains/connecting-domains#set-up-your-existing-domain-to-connect-to-shopify
    "shop.wellcomecollection.org" = "shops.myshopify.com"

    # Atlassion Statuspage (https://wellcomecollection.statuspage.io/)
    "status.wellcomecollection.org" = "qyhn8w55666p.stspg-customer.com"

    # Sectigo domain name validation records
    # Sent by Flavio V 29 October 2024
    "_0dc4e7168ed7814510307bb24b6f7418.wellcomecollection.org" = "699a0e70174c47ab5faaf2993303e2ad.962cb5fa70ca907c6d976adbedfe809a.sectigo.com"
    # Sent by Flavio V 27 October 2025
    "_1882c94c37766802a5e85c69567c4d4e.wellcomecollection.org" = "23f8ac140a4bb21ebe7d6a2cd2eac622.ec236ed453fc4227652e181ea1747c5e.sectigo.com"
  }

  # Subdomains that should be redirected to wellcomecollection.org
  redirect_subdomains_to_apex = [
    "alpha.wellcomecollection.org",
    "blog.wellcomecollection.org",
    "www.wellcomecollection.org",
  ]

  txt_records = {
    # This value was sent by Slack from Flavio V on 11 June 2024.
    # It's used for domain name validation.
    "_pki-validation.wellcomecollection.org" = "4BC7-9858-1376-FF06-DA6A-241D-9F06-F452"
  }
}

resource "aws_route53_record" "subdomains" {
  for_each = local.subdomain_cname_records

  name    = each.key
  records = [each.value]

  zone_id = data.aws_route53_zone.weco_zone.id
  type    = "CNAME"
  ttl     = 300

  provider = aws.dns
}

resource "aws_route53_record" "txt" {
  for_each = local.txt_records

  zone_id = data.aws_route53_zone.weco_zone.id
  name    = each.key
  type    = "TXT"
  records = [each.value]
  ttl     = 60

  provider = aws.dns
}

module "redirects" {
  for_each = toset(local.redirect_subdomains_to_apex)
  source   = "../../modules/redirect"

  from    = each.key
  to      = "wellcomecollection.org"
  zone_id = data.aws_route53_zone.weco_zone.id

  providers = {
    aws.dns = aws.dns
  }
}
