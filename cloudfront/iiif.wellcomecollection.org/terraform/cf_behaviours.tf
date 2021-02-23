locals {
  wellcome_images_path_patterns = [
    "image/A00*",
    "image/B00*",
    "image/L00*",
    "image/M00*",
    "image/N00*",
    "image/S00*",
    "image/V00*",
    "image/W00*",
  ]

  wellcome_images_loris_behaviours = concat([
    for pattern in local.wellcome_images_path_patterns :
    {
      path_pattern     = pattern
      target_origin_id = "loris"
      headers          = []
      cookies          = "none"
      lambdas          = []

      min_ttl     = 7 * 24 * 60 * 60
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    }
  ], [
    {
      path_pattern     = "image/s3:*"
      target_origin_id = "loris"
      headers          = []
      cookies          = "none"
      lambdas          = []

      min_ttl     = 7 * 24 * 60 * 60
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    }
  ])

  wellcome_images_dlcs_behaviours_prod = [
  for pattern in local.wellcome_images_path_patterns :
  {
    path_pattern     = pattern
    target_origin_id = "dlcs_wellcome_images"
    headers          = []
    cookies          = "none"
    lambdas = [
      {
        event_type = "origin-request"
        lambda_arn = local.dlcs_path_rewrite_arn_prod
      }
    ]

    min_ttl     = null
    default_ttl = null
    max_ttl     = null
  }
  ]

  wellcome_images_dlcs_behaviours_stage = [
    for pattern in local.wellcome_images_path_patterns :
    {
      path_pattern     = pattern
      target_origin_id = "dlcs_wellcome_images"
      headers          = []
      cookies          = "none"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.dlcs_path_rewrite_arn_stage
        }
      ]

      min_ttl     = null
      default_ttl = null
      max_ttl     = null
    }
  ]

  dlcs_images_behaviours_prod = [
    {
      path_pattern     = "image/*"
      target_origin_id = "dlcs_images"
      headers          = []
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.dlcs_path_rewrite_arn_prod
        }
      ]

      min_ttl     = 7 * 24 * 60 * 60
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    }
  ]

  dlcs_images_behaviours_stage = [
    {
      path_pattern     = "image/*"
      target_origin_id = "dlcs_images"
      headers          = []
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.dlcs_path_rewrite_arn_stage
        }
      ]

      min_ttl     = 7 * 24 * 60 * 60
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    }
  ]

  thumbs_behaviours = [
    {
      path_pattern     = "thumbs/*.*"
      target_origin_id = "dlcs"
      headers          = []
      cookies          = "all"
      lambdas          = []

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    },
    {
      path_pattern     = "thumbs/b*"
      target_origin_id = "iiif"
      headers          = ["*"]
      cookies          = "all"
      lambdas          = []

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    }
  ]

  av_behaviours = [
    {
      path_pattern     = "av/*"
      target_origin_id = "dlcs"
      headers          = []
      cookies          = "all"
      lambdas          = []

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    },
  ]

  pdf_behaviours = [
    {
      path_pattern     = "pdf/*"
      target_origin_id = "dlcs"
      headers          = []
      cookies          = "all"
      lambdas          = []

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    },
  ]

  dash_behaviours = [
    {
      path_pattern     = "dash/*"
      target_origin_id = "dds"
      headers          = ["*"]
      cookies          = "all"
      lambdas          = []

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    },
  ]

  text_behaviours = [
    {
      path_pattern     = "text/v1*"
      target_origin_id = "iiif"
      headers          = ["*"]
      cookies          = "all"
      lambdas          = []

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    },
  ]

  prod_behaviours = concat(
    // TODO: Remove this fallback line when Loris is decommissioned
    // local.wellcome_images_loris_behaviours,
    local.wellcome_images_dlcs_behaviours_prod,
    local.dlcs_images_behaviours_prod,
    local.thumbs_behaviours,
    local.av_behaviours,
    local.pdf_behaviours,
    local.dash_behaviours,
    local.text_behaviours,
  )

  stage_behaviours = concat(
    local.wellcome_images_dlcs_behaviours_stage,
    local.dlcs_images_behaviours_stage,
    local.thumbs_behaviours,
    local.av_behaviours,
    local.pdf_behaviours,
    local.dash_behaviours,
    local.text_behaviours,
  )

  test_behaviours = concat(
    local.wellcome_images_dlcs_behaviours_stage,
    local.dlcs_images_behaviours_stage,
    local.thumbs_behaviours,
    local.av_behaviours,
    local.pdf_behaviours,
    local.dash_behaviours,
    local.text_behaviours,
  )
}
