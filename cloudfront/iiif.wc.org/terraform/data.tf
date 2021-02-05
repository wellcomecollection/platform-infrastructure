data "aws_acm_certificate" "iiif_wc_org" {
  domain   = "iiif.wellcomecollection.org"
  statuses = ["ISSUED"]
  provider = aws.us_east_1
}
