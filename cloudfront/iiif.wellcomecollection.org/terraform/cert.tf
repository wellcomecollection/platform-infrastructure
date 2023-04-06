module "cert" {
  source = "github.com/wellcomecollection/terraform-aws-acm-certificate?ref=v1.0.0"

  domain_name = "iiif.wellcomecollection.org"

  subject_alternative_names = [
    "iiif-test.wellcomecollection.org",
    "iiif-prod.wellcomecollection.org",
    "iiif-stage.wellcomecollection.org",
  ]

  zone_id = data.aws_route53_zone.zone.id

  providers = {
    aws     = aws.us_east_1
    aws.dns = aws.dns
  }
}

# rather than alter the current, prod cert create a new one
# for temporary environment
module "cert_stagenew" {
  source = "github.com/wellcomecollection/terraform-aws-acm-certificate?ref=v1.0.0"

  domain_name = "iiif-stage-new.wellcomecollection.org"

  zone_id = data.aws_route53_zone.zone.id

  providers = {
    aws     = aws.us_east_1
    aws.dns = aws.dns
  }
}

data "aws_route53_zone" "zone" {
  provider = aws.dns

  name = "wellcomecollection.org."
}