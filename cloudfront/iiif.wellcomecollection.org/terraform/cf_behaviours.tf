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
      path_pattern     = "thumb/*"
      target_origin_id = "iiif"
      headers          = ["*"]
      cookies          = "none"
      lambdas          = []

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    }
  ]

  dlcs_thumbs_behaviours_prod = [
    {
      path_pattern     = "thumbs/*"
      target_origin_id = "dlcs_thumbs"
      headers          = []
      cookies          = "none"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.dlcs_path_rewrite_arn_prod
        }
      ]

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    }
  ]

  dlcs_thumbs_behaviours_stage = [
    {
      path_pattern     = "thumbs/*"
      target_origin_id = "dlcs_thumbs"
      headers          = ["X-Forwarded-Host"]
      cookies          = "none"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.dlcs_path_rewrite_arn_stage
        }
      ]

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    }
  ]

  av_behaviours_prod = [
    {
      path_pattern     = "av/*"
      target_origin_id = "dlcs_av"
      headers          = []
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.dlcs_path_rewrite_arn_prod
        }
      ]

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    },
  ]

  av_behaviours_stage = [
    {
      path_pattern     = "av/*"
      target_origin_id = "dlcs_av"
      headers          = []
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.dlcs_path_rewrite_arn_stage
        }
      ]

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    },
  ]

  pdf_behaviours_prod = [
    {
      path_pattern     = "pdf/*"
      target_origin_id = "dlcs_pdf"
      headers          = []
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.dlcs_path_rewrite_arn_prod
        }
      ]

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    },
  ]

  pdf_behaviours_stage = [
    {
      path_pattern     = "pdf/*"
      target_origin_id = "dlcs_pdf"
      headers          = []
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.dlcs_path_rewrite_arn_stage
        }
      ]

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    },
  ]

  file_behaviours_prod = [
    {
      path_pattern     = "file/*"
      target_origin_id = "dlcs_file"
      headers          = []
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.dlcs_path_rewrite_arn_prod
        }
      ]

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    },
  ]

  file_behaviours_stage = [
    {
      path_pattern     = "file/*"
      target_origin_id = "dlcs_file"
      headers          = []
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.dlcs_path_rewrite_arn_stage
        }
      ]

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    },
  ]

  auth_behaviours_prod = [
    {
      path_pattern     = "auth/*"
      target_origin_id = "dlcs_auth"
      headers          = ["Authorization"]
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.dlcs_path_rewrite_arn_prod
        }
      ]

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    },
  ]

  auth_behaviours_stage = [
    {
      path_pattern     = "auth/*"
      target_origin_id = "dlcs_auth"
      headers          = ["Authorization"]
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.dlcs_path_rewrite_arn_stage
        }
      ]

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    },
  ]

  dash_behaviours = [
    {
      path_pattern     = "dash/*"
      target_origin_id = "dashboard"
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

  pdf_cover_behaviours = [
    {
      path_pattern     = "pdf-cover/*"
      target_origin_id = "pdf_cover"
      headers          = []
      cookies          = "none"
      lambdas          = []

      min_ttl     = 0
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60
    },
  ]

  prod_behaviours = concat(
    local.wellcome_images_dlcs_behaviours_prod,
    local.dlcs_images_behaviours_prod,
    local.thumbs_behaviours,
    local.dlcs_thumbs_behaviours_prod,
    local.av_behaviours_prod,
    local.pdf_behaviours_prod,
    local.file_behaviours_prod,
    local.auth_behaviours_prod,
    local.dash_behaviours,
    local.text_behaviours,
    local.pdf_cover_behaviours,
  )

  stage_behaviours = concat(
    local.wellcome_images_dlcs_behaviours_stage,
    local.dlcs_images_behaviours_stage,
    local.thumbs_behaviours,
    local.dlcs_thumbs_behaviours_stage,
    local.av_behaviours_stage,
    local.pdf_behaviours_stage,
    local.file_behaviours_stage,
    local.auth_behaviours_stage,
    local.dash_behaviours,
    local.text_behaviours,
    local.pdf_cover_behaviours,
  )

  test_behaviours = concat(
    local.wellcome_images_dlcs_behaviours_stage,
    local.dlcs_images_behaviours_stage,
    local.thumbs_behaviours,
    local.dlcs_thumbs_behaviours_stage,
    local.av_behaviours_stage,
    local.pdf_behaviours_stage,
    local.file_behaviours_stage,
    local.auth_behaviours_stage,
    local.dash_behaviours,
    local.text_behaviours,
    local.pdf_cover_behaviours,
  )
}
