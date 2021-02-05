data "aws_acm_certificate" "roadmap_wc_org" {
  domain   = "roadmap.wellcomecollection.org"
  statuses = ["ISSUED"]
  provider = aws.us_east_1
}
