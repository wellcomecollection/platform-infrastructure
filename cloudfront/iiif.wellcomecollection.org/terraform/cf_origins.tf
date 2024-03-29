// We have manually enable Origin Shield for some origins
// in order to increase the cache hit ratio.
// Where this is the case, origins will be annotated.
// See: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/origin-shield.html
// It cannot be enabled with Terraform at time of writing.
// See: https://github.com/hashicorp/terraform-provider-aws/issues/15752

module "dashboard_origin_set" {
  source = "./origin_sets"
  id     = "dashboard"

  prod = {
    domain_name : "dash.wellcomecollection.digirati.io"
    origin_path : ""
  }
  stage = {
    domain_name : "dash-stage.wellcomecollection.digirati.io"
    origin_path : ""
  }
  test = {
    domain_name : "dash-test.wellcomecollection.digirati.io"
    origin_path : ""
  }
}

module "iiif_origin_set" {
  source = "./origin_sets"
  id     = "iiif"

  prod = {
    domain_name : "dds.wellcomecollection.digirati.io"
    origin_path : ""
  }
  stage = {
    domain_name : "dds-stage.wellcomecollection.digirati.io"
    origin_path : ""
  }
  test = {
    domain_name : "dds-test.wellcomecollection.digirati.io"
    origin_path : ""
  }
}

module "dlcs_origin_set" {
  source = "./origin_sets"
  id     = "dlcs"

  prod = {
    domain_name : "dlcs.io"
    origin_path : ""
  }
  stage = {
    domain_name : "dlcs.io"
    origin_path : ""
  }
  test = {
    domain_name : "dlcs.io"
    origin_path : ""
  }
}

// These are the set of images sourced from the defunct "Wellcome Images" site
// Corresponding to DLCS "Space 8"
module "dlcs_wellcome_images_origin_set" {
  // Origin Shield is enabled in prod for this origin
  source = "./origin_sets"
  id     = "dlcs_wellcome_images"

  forward_host = true

  prod = {
    domain_name : "dlcs.io"
    origin_path : "/iiif-img/wellcome/8"
  }
  stage = {
    domain_name : "dlcs.io"
    origin_path : "/iiif-img/wellcome/8"
  }
  test = {
    domain_name : "dlcs.io"
    origin_path : "/iiif-img/wellcome/8"
  }
}

// These are the set of all other images served by DLCS
// Corresponding to DLCS "Space 5"
module "dlcs_images_origin_set" {
  // Origin Shield is enabled in prod for this origin
  source = "./origin_sets"
  id     = "dlcs_images"

  forward_host = true

  prod = {
    domain_name : "dlcs.io"
    origin_path : "/iiif-img/wellcome/5"
  }
  stage = {
    domain_name : "dlcs.io"
    origin_path : "/iiif-img/wellcome/6"
  }
  test = {
    domain_name : "dlcs.io"
    origin_path : "/iiif-img/wellcome/9"
  }
}

// Corresponding to DLCS "Space 8"
module "dlcs_wellcome_thumbs_origin_set" {
  source = "./origin_sets"
  id     = "dlcs_wellcome_thumbs"

  forward_host = true

  prod = {
    domain_name : "dlcs.io"
    origin_path : "/thumbs/wellcome/8"
  }
  stage = {
    domain_name : "dlcs.io"
    origin_path : "/thumbs/wellcome/8"
  }
  test = {
    domain_name : "dlcs.io"
    origin_path : "/thumbs/wellcome/8"
  }
}

module "dlcs_thumbs_origin_set" {
  source = "./origin_sets"
  id     = "dlcs_thumbs"

  forward_host = true

  prod = {
    domain_name : "dlcs.io"
    origin_path : "/thumbs/wellcome/5"
  }
  stage = {
    domain_name : "dlcs.io"
    origin_path : "/thumbs/wellcome/6"
  }
  test = {
    domain_name : "dlcs.io"
    origin_path : "/thumbs/wellcome/9"
  }
}

module "dlcs_av_origin_set" {
  source = "./origin_sets"
  id     = "dlcs_av"

  forward_host = true

  prod = {
    domain_name : "dlcs.io"
    origin_path : "/iiif-av/wellcome/5"
  }
  stage = {
    domain_name : "dlcs.io"
    origin_path : "/iiif-av/wellcome/6"
  }
  test = {
    domain_name : "dlcs.io"
    origin_path : "/iiif-av/wellcome/9"
  }
}

module "dlcs_pdf_origin_set" {
  source = "./origin_sets"
  id     = "dlcs_pdf"

  prod = {
    domain_name : "dlcs.io"
    origin_path : "/pdf/wellcome/pdf/5"
  }
  stage = {
    domain_name : "dlcs.io"
    origin_path : "/pdf/wellcome/pdf/6"
  }
  test = {
    domain_name : "dlcs.io"
    origin_path : "/pdf/wellcome/pdf/9"
  }
}

module "dlcs_file_origin_set" {
  source = "./origin_sets"
  id     = "dlcs_file"

  prod = {
    domain_name : "dlcs.io"
    origin_path : "/file/wellcome/5"
  }
  stage = {
    domain_name : "dlcs.io"
    origin_path : "/file/wellcome/6"
  }
  test = {
    domain_name : "dlcs.io"
    origin_path : "/file/wellcome/9"
  }
}

module "dlcs_pdf_cover_origin_set" {
  source = "./origin_sets"
  id     = "pdf_cover"

  prod = {
    domain_name : "pdf.wellcomecollection.digirati.io"
    origin_path : ""
  }
  stage = {
    domain_name : "pdf-stage.wellcomecollection.digirati.io"
    origin_path : ""
  }
  test = {
    domain_name : "pdf-stage.wellcomecollection.digirati.io"
    origin_path : ""
  }
}

module "dlcs_auth_origin_set" {
  source = "./origin_sets"
  id     = "dlcs_auth"

  forward_host = true

  prod = {
    domain_name : "dlcs.io"
    origin_path : "/auth/2"
  }
  stage = {
    domain_name : "dlcs.io"
    origin_path : "/auth/2"
  }
  test = {
    domain_name : "dlcs.io"
    origin_path : "/auth/2"
  }
}

module "dlcs_auth2_origin_set" {
  source = "./origin_sets"
  id     = "dlcs_auth_v2"

  forward_host = true

  prod = {
    domain_name : "dlcs.io"
    origin_path : "/auth/v2/access/2"
  }
  stage = {
    domain_name : "dlcs.io"
    origin_path : "/auth/v2/access/2"
  }
  test = {
    domain_name : "dlcs.io"
    origin_path : "/auth/v2/access/2"
  }
}

module "dlcs_auth2_probe_origin_set" {
  source = "./origin_sets"
  id     = "dlcs_auth_v2_probe"

  forward_host = true

  prod = {
    domain_name : "dlcs.io"
    origin_path : "/auth/v2/probe/2/5"
  }
  stage = {
    domain_name : "dlcs.io"
    origin_path : "/auth/v2/probe/2/6"
  }
  test = {
    domain_name : "dlcs.io"
    origin_path : "/auth/v2/probe/2/9"
  }
}

locals {

  prod_origins = [
    module.dashboard_origin_set.origins["prod"],
    module.iiif_origin_set.origins["prod"],
    module.dlcs_origin_set.origins["prod"],
    module.dlcs_wellcome_images_origin_set.origins["prod"],
    module.dlcs_wellcome_thumbs_origin_set.origins["prod"],
    module.dlcs_images_origin_set.origins["prod"],
    module.dlcs_thumbs_origin_set.origins["prod"],
    module.dlcs_av_origin_set.origins["prod"],
    module.dlcs_pdf_origin_set.origins["prod"],
    module.dlcs_file_origin_set.origins["prod"],
    module.dlcs_pdf_cover_origin_set.origins["prod"],
    module.dlcs_auth_origin_set.origins["prod"],
    module.dlcs_auth2_origin_set.origins["prod"],
    module.dlcs_auth2_probe_origin_set.origins["prod"]
  ]

  stage_origins = [
    module.dashboard_origin_set.origins["stage"],
    module.iiif_origin_set.origins["stage"],
    module.dlcs_origin_set.origins["stage"],
    module.dlcs_wellcome_images_origin_set.origins["stage"],
    module.dlcs_wellcome_thumbs_origin_set.origins["stage"],
    module.dlcs_images_origin_set.origins["stage"],
    module.dlcs_thumbs_origin_set.origins["stage"],
    module.dlcs_av_origin_set.origins["stage"],
    module.dlcs_pdf_origin_set.origins["stage"],
    module.dlcs_file_origin_set.origins["stage"],
    module.dlcs_pdf_cover_origin_set.origins["stage"],
    module.dlcs_auth_origin_set.origins["stage"],
    module.dlcs_auth2_origin_set.origins["stage"],
    module.dlcs_auth2_probe_origin_set.origins["stage"]
  ]

  test_origins = [
    module.dashboard_origin_set.origins["test"],
    module.iiif_origin_set.origins["test"],
    module.dlcs_origin_set.origins["test"],
    module.dlcs_wellcome_images_origin_set.origins["test"],
    module.dlcs_wellcome_thumbs_origin_set.origins["test"],
    module.dlcs_images_origin_set.origins["test"],
    module.dlcs_thumbs_origin_set.origins["test"],
    module.dlcs_av_origin_set.origins["test"],
    module.dlcs_pdf_origin_set.origins["test"],
    module.dlcs_file_origin_set.origins["test"],
    module.dlcs_pdf_cover_origin_set.origins["test"],
    module.dlcs_auth_origin_set.origins["test"],
    module.dlcs_auth2_origin_set.origins["test"],
    module.dlcs_auth2_probe_origin_set.origins["test"]
  ]
}