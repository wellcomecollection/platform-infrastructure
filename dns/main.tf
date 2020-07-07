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

# We just create the bucket here instead of using a redirect module
# as wellcomelibrary.org is externally managed for now
resource "aws_s3_bucket" "alpha_redirect" {
  bucket = "alpha.wellcomelibrary.org"
  acl    = "private"

  website {
    redirect_all_requests_to = "github.com/wellcomecollection/alpha"
  }
}
