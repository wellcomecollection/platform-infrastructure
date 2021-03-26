module "wellcomelibrary-prod" {
  source = "./cloudfront_distro"

  distro_alternative_names = [
    "wellcomelibrary.org",
    "www.wellcomelibrary.org"
  ]

  acm_certificate_arn = module.cert.arn

  origins    = local.prod_origins
  behaviours = local.prod_behaviours

  default_target_origin_id                       = "origin"
  default_lambda_function_association_event_type = "origin-request"
  default_lambda_function_association_lambda_arn = local.wellcome_library_passthru_arn_prod

  default_forwarded_headers = ["Host"]
}

module "wellcomelibrary-stage" {
  source = "./cloudfront_distro"

  distro_alternative_names = [
    "stage.wellcomelibrary.org",
    "www.stage.wellcomelibrary.org",
  ]
  acm_certificate_arn = module.cert-stage.arn

  origins    = local.stage_origins
  behaviours = local.stage_behaviours

  default_target_origin_id                       = "origin"
  default_lambda_function_association_event_type = "origin-request"
  default_lambda_function_association_lambda_arn = local.wellcome_library_passthru_arn_stage

  // For a description of CloudFront-Forwarded-Proto see:
  // https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-cloudfront-headers.html
  default_forwarded_headers = ["Host", "CloudFront-Forwarded-Proto"]
}
