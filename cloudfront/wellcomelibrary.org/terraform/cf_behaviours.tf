locals {
  api_behaviours = [
    {
      path_pattern     = "iiif/*"
      target_origin_id = "origin"
      headers          = []
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.wellcome_library_passthru_arn_prod
        }
      ]

      min_ttl     = null
      default_ttl = null
      max_ttl     = null
    },
    {
      path_pattern     = "service/*"
      target_origin_id = "origin"
      headers          = []
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.wellcome_library_passthru_arn_prod
        }
      ]

      min_ttl     = null
      default_ttl = null
      max_ttl     = null
    },
    {
      path_pattern     = "ddsconf/*"
      target_origin_id = "origin"
      headers          = []
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.wellcome_library_passthru_arn_prod
        }
      ]

      min_ttl     = null
      default_ttl = null
      max_ttl     = null
    },
    {
      path_pattern     = "dds-static/*"
      target_origin_id = "origin"
      headers          = []
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.wellcome_library_passthru_arn_prod
        }
      ]

      min_ttl     = null
      default_ttl = null
      max_ttl     = null
    },
    {
      path_pattern     = "annoservices/*"
      target_origin_id = "origin"
      headers          = []
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.wellcome_library_passthru_arn_prod
        }
      ]

      min_ttl     = null
      default_ttl = null
      max_ttl     = null
    },
  ]

  items_behaviours = [
    {
      path_pattern     = "item/*"
      target_origin_id = "origin"
      headers          = []
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.wellcome_library_passthru_arn_prod
        }
      ]

      min_ttl     = null
      default_ttl = null
      max_ttl     = null
    }
  ]

  moh_paths = ["moh/*", "spas/*", "assets/*", "plugins/*", "scripts/*", "timelines/*"]

  moh_behaviours = [
    for path in local.moh_paths :
    {
      path_pattern     = path
      target_origin_id = local.wellcome_library_moh_origin.origin_id
      headers          = []
      cookies          = "all"
      lambdas          = []

      min_ttl     = null
      default_ttl = null
      max_ttl     = null
    }
  ]

  prod_behaviours = concat(
    local.moh_behaviours,
  )

  stage_behaviours = concat(
    local.moh_behaviours,
  )
}
