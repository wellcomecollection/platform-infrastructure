data "aws_acm_certificate" "logging_wc_org" {
  domain   = "logging.wellcomecollection.org"
  statuses = ["ISSUED"]
  provider = aws.us_east_1
}
