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
