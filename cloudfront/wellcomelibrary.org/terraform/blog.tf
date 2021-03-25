module "wellcomelibrary_blog-prod" {
  source = "./cloudfront_distro"

  distro_alternative_names = [
    "blog.wellcomelibrary.org"
  ]
  acm_certificate_arn = module.cert-stage.arn

  origins = [{
    origin_id : "origin"
    domain_name : "origin.wellcomelibrary.org"
    origin_path : null
  }]

  default_target_origin_id                       = "origin"
  default_lambda_function_association_event_type = "origin-request"
  default_lambda_function_association_lambda_arn = local.wellcome_library_blog_redirect_arn_prod
}

module "wellcomelibrary_blog-stage" {
  source = "./cloudfront_distro"

  distro_alternative_names = [
    "blog.stage.wellcomelibrary.org"
  ]
  acm_certificate_arn = module.cert-stage.arn

  origins = [{
    origin_id : "origin"
    domain_name : "origin.wellcomelibrary.org"
    origin_path : null
  }]

  default_target_origin_id                       = "origin"
  default_lambda_function_association_event_type = "origin-request"
  default_lambda_function_association_lambda_arn = local.wellcome_library_blog_redirect_arn_stage
}

resource "aws_route53_record" "blog-prod" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "blog.wellcomelibrary.org"
  type    = "CNAME"
  // This is the previous on-premise address, if required for easy roll-back
  //records = ["bloglibrary.wpengine.com"]
  records = [module.wellcomelibrary_blog-prod.distro_domain_name]
  ttl     = "60"

  provider = aws.dns
}

resource "aws_route53_record" "blog-stage" {
  zone_id = data.aws_route53_zone.zone.id
  name    = "blog.stage.wellcomelibrary.org"
  type    = "CNAME"
  records = [module.wellcomelibrary_blog-stage.distro_domain_name]
  ttl     = "60"

  provider = aws.dns
}