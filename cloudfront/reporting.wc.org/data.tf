data "aws_acm_certificate" "reporting_wc_org" {
  domain   = "reporting.wellcomecollection.org"
  statuses = ["ISSUED"]
  provider = aws.us_east_1
}
