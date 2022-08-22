locals {
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
  }

  # Subdomains that should be redirected to wellcomecollection.org
  redirect_subdomains_to_apex = [
    "www.wellcomecollection.org",
  ]
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

moved {
  from = aws_route53_record.docs
  to   = aws_route53_record.subdomains["docs"]
}

moved {
  from = aws_route53_record.subdomains["docs"]
  to   = aws_route53_record.subdomains["docs.wellcomecollection.org"]
}

moved {
  from = aws_route53_record.cardigan
  to   = aws_route53_record.subdomains["cardigan.wellcomecollection.org"]
}

moved {
  from = aws_route53_record.rank
  to   = aws_route53_record.subdomains["rank.wellcomecollection.org"]
}

moved {
  from = aws_route53_record.status
  to   = aws_route53_record.subdomains["status.wellcomecollection.org"]
}

moved {
  from = aws_route53_record.shop
  to   = aws_route53_record.subdomains["shop.wellcomecollection.org"]
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

moved {
  from = module.www
  to   = module.redirects["www.wellcomecollection.org"]
}
