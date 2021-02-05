module "iiif-prod" {
  source = "./cloudfront_distro"

  environment         = "prod"
  acm_certificate_arn = data.aws_acm_certificate.iiif_wc_org.arn
}

module "iiif-stage" {
  source = "./cloudfront_distro"

  environment         = "stage"
  acm_certificate_arn = data.aws_acm_certificate.iiif_wc_org.arn

  dlcs_lambda_associations = [
    {
      event_type = "origin-request"
      lambda_arn = local.dlcs_path_rewrite_arn_latest
    }
  ]

  # Temporary variable to differentiate prod/stage cache behaviour
  # Defaults to "loris" where unspecified
  miro_sourced_images_target = "dlcs_space_8"
}

module "iiif-test" {
  source = "./cloudfront_distro"

  environment         = "test"
  acm_certificate_arn = data.aws_acm_certificate.iiif_wc_org.arn
}
