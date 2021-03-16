locals {
  prod_behaviours = [
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
  stage_behaviours = [
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
    },
    {
      path_pattern     = "events*"
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
}
