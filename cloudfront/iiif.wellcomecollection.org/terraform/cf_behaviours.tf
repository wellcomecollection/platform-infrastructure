locals {
  wellcome_images_path_patterns = [
    "image/V00*",
    "image/L00*",
    "image/M00*",
    "image/B00*",
    "image/N00*",
    "image/A00*",
    "image/W00*",
    "image/S00*"
  ]

  wellcome_images_behaviours = [
    for pattern in local.wellcome_images_path_patterns :
    {
      path_pattern     = pattern
      target_origin_id = "loris"
      headers          = []
      cookies          = "none"
      lambdas          = []
    }
  ]

  wellcome_images_stage_behaviours = [
    for pattern in local.wellcome_images_path_patterns :
    {
      path_pattern     = pattern
      target_origin_id = "dlcs_space_8"
      headers          = []
      cookies          = "none"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.dlcs_path_rewrite_arn_latest
        }
      ]
    }
  ]



  behaviours       = local.wellcome_images_behaviours
  stage_behaviours = local.wellcome_images_stage_behaviours
}