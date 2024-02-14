module "iiif-waf-prod" {
  source = "./waf"
  stage  = "prod"

  providers = {
    aws = aws.us_east_1
  }
}

module "iiif-prod" {
  source = "./cloudfront_distro"

  environment         = "prod"
  acm_certificate_arn = module.cert.arn

  origins    = local.prod_origins
  behaviours = local.prod_behaviours

  logging_bucket = aws_s3_bucket.cloudfront_logs.id

  default_target_origin_id = "iiif"

  web_acl_id = module.iiif-waf-prod.web_acl_arn

  providers = {
    aws.dns = aws.dns
  }
}

module "iiif-waf-stage" {
  source = "./waf"
  stage  = "stage"

  providers = {
    aws = aws.us_east_1
  }
}

module "iiif-stage" {
  source = "./cloudfront_distro"

  environment         = "stage"
  acm_certificate_arn = module.cert.arn

  origins    = local.stage_origins
  behaviours = local.stage_behaviours

  logging_bucket = aws_s3_bucket.cloudfront_logs.id

  default_target_origin_id = "iiif"

  web_acl_id = module.iiif-waf-stage.web_acl_arn

  providers = {
    aws.dns = aws.dns
  }
}

module "iiif-waf-test" {
  source = "./waf"
  stage  = "test"

  providers = {
    aws = aws.us_east_1
  }
}

module "iiif-test" {
  source = "./cloudfront_distro"

  environment         = "test"
  acm_certificate_arn = module.cert.arn

  origins    = local.test_origins
  behaviours = local.test_behaviours

  logging_bucket = aws_s3_bucket.cloudfront_logs.id

  default_target_origin_id = "iiif"

  web_acl_id = module.iiif-waf-test.web_acl_arn

  providers = {
    aws.dns = aws.dns
  }
}
