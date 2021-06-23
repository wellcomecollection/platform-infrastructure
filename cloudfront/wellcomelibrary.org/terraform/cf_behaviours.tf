locals {
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
