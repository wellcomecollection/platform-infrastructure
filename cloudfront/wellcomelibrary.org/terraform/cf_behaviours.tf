locals {
  example_prod_behaviours = [
    {
      path_pattern     = "foo/*"
      target_origin_id = "example"
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
    },
  ]

  prod_behaviours = concat(
    local.example_prod_behaviours
  )

  stage_behaviours = concat(
    local.example_prod_behaviours
  )
}
