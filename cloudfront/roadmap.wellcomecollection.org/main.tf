module "productboard-wellcomecollection" {
  source = "./cloudfront_distro"

  alias   = "roadmap.wellcomecollection.org"
  comment = "productboard (roadmap)"

  acm_certificate_arn = module.cert.arn
}
