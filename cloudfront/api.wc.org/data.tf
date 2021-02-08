data "aws_acm_certificate" "api_wc_org" {
  domain   = "api.wellcomecollection.org"
  statuses = ["ISSUED"]
  provider = aws.us_east_1
}
