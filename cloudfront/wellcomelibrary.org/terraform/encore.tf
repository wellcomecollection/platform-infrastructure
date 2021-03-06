// Encore links (search.wellcomelibrary.org)

//module "wellcomelibrary_encore-prod" {
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
module "wellcomelibrary_encore-stage" {
  source = "./cloudfront_distro"

  distro_alternative_names = [
    "search.stage.wellcomelibrary.org"
  ]
  acm_certificate_arn = module.cert-stage.arn

  origins = [{
    origin_id : "origin"
    domain_name : "search.origin.wellcomelibrary.org"
    origin_path : null
    origin_protocol_policy : "http-only"
  }]

  default_target_origin_id                       = "origin"
  default_lambda_function_association_event_type = "origin-request"
  default_lambda_function_association_lambda_arn = local.wellcome_library_encore_redirect_arn_stage
  default_forwarded_headers                      = ["Host"]
}

resource "aws_route53_record" "encore-prod" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "search.wellcomelibrary.org"
  type    = "A"

  records = ["35.176.25.168"]
  ttl     = "300"

  provider = aws.dns
}

resource "aws_route53_record" "encore-origin" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "search.origin.wellcomelibrary.org"
  type    = "A"

  records = ["35.176.25.168"]
  ttl     = "60"

  provider = aws.dns
}

resource "aws_route53_record" "encore-stage" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "search.stage.wellcomelibrary.org"
  type    = "CNAME"
  records = [module.wellcomelibrary_encore-stage.distro_domain_name]
  ttl     = "60"

  provider = aws.dns
}