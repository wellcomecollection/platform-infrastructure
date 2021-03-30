// OPAC links (catalogue.wellcomelibrary.org)

//module "wellcomelibrary_opac-prod" {
//  source = "./cloudfront_distro"
//
//  distro_alternative_names = [
//    "catalogue.wellcomelibrary.org"
//  ]
//  acm_certificate_arn = module.cert-stage.arn
//
//  origins = [{
//    origin_id : "origin"
//    domain_name : "catalogue.origin.wellcomelibrary.org"
//    origin_path : null
//  }]
//
//  default_target_origin_id                       = "origin"
//  default_lambda_function_association_event_type = "origin-request"
//  default_lambda_function_association_lambda_arn = local.wellcome_library_passthru_arn_prod
//  default_forwarded_headers                      = ["Host"]
//}
//
module "wellcomelibrary_opac-stage" {
  source = "./cloudfront_distro"

  distro_alternative_names = [
    "catalogue.stage.wellcomelibrary.org"
  ]
  acm_certificate_arn = module.cert-stage.arn

  origins = [{
    origin_id : "origin"
    domain_name : "catalogue.origin.wellcomelibrary.org"
    origin_path : null
    origin_protocol_policy: "match-viewer"
  }]

  default_target_origin_id                       = "origin"
  default_lambda_function_association_event_type = "origin-request"
  default_lambda_function_association_lambda_arn = local.wellcome_library_passthru_arn_prod
  default_forwarded_headers                      = ["Host"]
}

resource "aws_route53_record" "opac-prod" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "catalogue.wellcomelibrary.org"
  type    = "A"

  records = ["195.143.129.134"]
  ttl     = "300"

  provider = aws.dns
}

resource "aws_route53_record" "opac-origin" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "catalogue.origin.wellcomelibrary.org"
  type    = "A"

  records = ["195.143.129.134"]
  ttl     = "60"

  provider = aws.dns
}

resource "aws_route53_record" "opac-stage" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "catalogue.stage.wellcomelibrary.org"
  type    = "CNAME"
  records = [module.wellcomelibrary_opac-stage.distro_domain_name]
  ttl     = "60"

  provider = aws.dns
}