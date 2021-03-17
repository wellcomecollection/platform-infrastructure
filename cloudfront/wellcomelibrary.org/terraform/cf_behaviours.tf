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
          lambda_arn = local.wellcome_library_redirect_arn_stage
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
          lambda_arn = local.wellcome_library_redirect_arn_stage
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
          lambda_arn = local.wellcome_library_redirect_arn_stage
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
          lambda_arn = local.wellcome_library_redirect_arn_stage
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
          lambda_arn = local.wellcome_library_redirect_arn_stage
        }
      ]

      min_ttl     = null
      default_ttl = null
      max_ttl     = null
    },
  ]

  static_redirects_behaviours = [
    {
      path_pattern     = "collections*"
      target_origin_id = "origin"
      headers          = []
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.wellcome_library_redirect_arn_stage
        }
      ]

      min_ttl     = null
      default_ttl = null
      max_ttl     = null
    },
    {
      path_pattern     = "using-the-library*"
      target_origin_id = "origin"
      headers          = []
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.wellcome_library_redirect_arn_stage
        }
      ]

      min_ttl     = null
      default_ttl = null
      max_ttl     = null
    },
  ]

  events_behaviours = [
    {
      path_pattern     = "events*"
      target_origin_id = "origin"
      headers          = []
      cookies          = "all"
      lambdas = [
        {
          event_type = "origin-request"
          lambda_arn = local.wellcome_library_redirect_arn_prod
        }
      ]

      min_ttl     = null
      default_ttl = null
      max_ttl     = null
    }
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
          lambda_arn = local.wellcome_library_redirect_arn_stage
        }
      ]

      min_ttl     = null
      default_ttl = null
      max_ttl     = null
    }
  ]

  prod_behaviours = local.events_behaviours

  stage_behaviours = concat(
    local.static_redirects_behaviours,
    local.events_behaviours,
    local.items_behaviours,
    local.api_behaviours
  )
}
