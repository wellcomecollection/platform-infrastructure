locals {
  example_behaviours = [
    {
      path_pattern     = "example/*"
      target_origin_id = "example"
      headers          = []
      cookies          = "all"
      lambdas          = []

      min_ttl     = null
      default_ttl = null
      max_ttl     = null
    },
  ]

  prod_behaviours = concat(
    local.example_behaviours
  )

  stage_behaviours = concat(
    local.example_behaviours
  )
}
