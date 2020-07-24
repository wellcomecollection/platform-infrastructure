data "aws_acm_certificate" "api_wc_org" {
  domain   = "api.wellcomecollection.org"
  statuses = ["ISSUED"]
  provider = aws.us_east_1
}

data "aws_acm_certificate" "iiif_wc_org" {
  domain   = "iiif.wellcomecollection.org"
  statuses = ["ISSUED"]
  provider = aws.us_east_1
}

data "aws_acm_certificate" "reporting_wc_org" {
  domain   = "reporting.wellcomecollection.org"
  statuses = ["ISSUED"]
  provider = aws.us_east_1
}

data "aws_acm_certificate" "logging_wc_org" {
  domain   = "logging.wellcomecollection.org"
  statuses = ["ISSUED"]
  provider = aws.us_east_1
}
