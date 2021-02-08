module "productboard-wellcomecollection" {
  source = "./cloudfront_distro"

  alias   = "roadmap.wellcomecollection.org"
  comment = "productboard (roadmap)"

  acm_certificate_arn = data.aws_acm_certificate.roadmap_wc_org.arn
}