data "aws_acm_certificate" "api_wc_org" {
  domain   = "api.wellcomecollection.org"
  statuses = ["ISSUED"]
  provider = aws.us_east_1
}

data "aws_acm_certificate" "raodmap_wc_org" {
  domain   = "roadmap.wellcomecollection.org"
  statuses = ["ISSUED"]
  provider = aws.us_east_1
}
