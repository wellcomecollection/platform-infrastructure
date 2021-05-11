locals {
  wellcome_library_origin = {
    origin_id : "origin"
    domain_name : "origin.wellcomelibrary.org"
    origin_path : null
    origin_protocol_policy : "match-viewer"
  }

  wellcome_library_moh_origin = {
    origin_id : "moh_origin"
    domain_name : "moh.wellcomecollection.digirati.io"
    origin_path : null
    origin_protocol_policy : "match-viewer"
  }

  prod_origins = [
    local.wellcome_library_origin
  ]

  stage_origins = [
    local.wellcome_library_origin,
    local.wellcome_library_moh_origin
  ]
}