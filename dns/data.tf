data "aws_route53_zone" "weco_zone" {
  provider = aws.dns
  name     = "wellcomecollection.org."
}

data "aws_route53_zone" "wellcomelibrary" {
  provider = aws.dns
  name     = "wellcomelibrary.org."
}
