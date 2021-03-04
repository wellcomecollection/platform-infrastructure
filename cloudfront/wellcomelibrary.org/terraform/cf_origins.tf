locals {
  wellcome_library_origin = {
    origin_id : "origin"
    domain_name : "origin.wellcomelibrary.org"
    origin_path : null
  }

  prod_origins = [
    local.wellcome_library_origin
  ]

  stage_origins = [
    local.wellcome_library_origin
  ]
}