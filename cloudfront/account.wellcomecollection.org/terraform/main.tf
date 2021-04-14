# Delegates access to the identity account hosted zone
# See: https://github.com/wellcomecollection/identity

data "aws_route53_zone" "weco_zone" {
  name     = "wellcomecollection.org."
  provider = aws.dns
}

/*
resource "aws_route53_record" "account-ns" {
  zone_id = data.aws_route53_zone.weco_zone.id
  name    = "account.${data.aws_route53_zone.weco_zone.name}"
  type    = "NS"
  ttl     = "300"
  records = local.account_zone_name_servers

  provider = aws.dns
}
*/

resource "aws_route53_record" "identity-ses-txt" {
  zone_id = data.aws_route53_zone.weco_zone.id
  name    = "_amazonses.${data.aws_route53_zone.weco_zone.name}"
  type    = "TXT"
  ttl     = "300"
  records = local.identity_ses_txt_records

  provider = aws.dns
}

resource "aws_route53_record" "identity-ses-dkim-cname" {
  for_each = local.identity_ses_dkim_records

  zone_id = data.aws_route53_zone.weco_zone.id
  name    = "${each.value}._domainkey.${data.aws_route53_zone.weco_zone.name}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${each.value}.dkim.amazonses.com"]

  provider = aws.dns
}
