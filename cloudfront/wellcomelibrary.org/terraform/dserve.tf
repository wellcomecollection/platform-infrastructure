// DServe links (archives.wellcomelibrary.org)

//module "wellcomelibrary_dserve-prod" {
//  source = "./cloudfront_distro"
//
//  distro_alternative_names = [
//    "archives.wellcomelibrary.org"
//  ]
//  acm_certificate_arn = module.cert-stage.arn
//
//  origins = [{
//    origin_id : "origin"
//    domain_name : "archives.origin.wellcomelibrary.org"
//    origin_path : null
//  }]
//
//  default_target_origin_id                       = "origin"
//  default_lambda_function_association_event_type = "origin-request"
//  default_lambda_function_association_lambda_arn = local.wellcome_library_passthru_arn_prod
//  default_forwarded_headers                      = ["Host"]
//}
//
module "wellcomelibrary_dserve-stage" {
  source = "./cloudfront_distro"

  distro_alternative_names = [
    "archives.stage.wellcomelibrary.org"
  ]
  acm_certificate_arn = module.cert-stage.arn

  origins = [{
    origin_id : "origin"
    domain_name : "archives.origin.wellcomelibrary.org"
    origin_path : null
    origin_protocol_policy: "http-only"
  }]

  default_target_origin_id                       = "origin"
  default_lambda_function_association_event_type = "origin-request"
  default_lambda_function_association_lambda_arn = local.wellcome_library_archive_redirect_arn_prod
  default_forwarded_headers                      = ["Host"]
}

resource "aws_route53_record" "dserve-prod" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "archives.wellcomelibrary.org"
  type    = "CNAME"

  records = ["archives.wellcome.ac.uk."]
  ttl     = "300"

  provider = aws.dns
}

resource "aws_route53_record" "dserve-origin" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "archives.origin.wellcomelibrary.org"
  type    = "CNAME"

  records = ["archives.wellcome.ac.uk."]
  ttl     = "60"

  provider = aws.dns
}

resource "aws_route53_record" "dserve-stage" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "archives.stage.wellcomelibrary.org"
  type    = "CNAME"
  records = [module.wellcomelibrary_dserve-stage.distro_domain_name]
  ttl     = "60"

  provider = aws.dns
}