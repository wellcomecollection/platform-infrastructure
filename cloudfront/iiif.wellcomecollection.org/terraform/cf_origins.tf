locals {
  prod_origins = [
    {
      origin_id : "dds"
      domain_name : "dds.dlcs.io"
      origin_path : null
    },
    {
      origin_id : "loris"
      domain_name : "iiif-origin.wellcomecollection.org"
      origin_path : null
    },
    {
      origin_id : "iiif"
      domain_name : "iiif.dlcs.io"
      origin_path : null
    },
    {
      origin_id : "dlcs"
      domain_name : "dlcs.io"
      origin_path : null
    },
    {
      origin_id   = "dlcs_wellcome_images"
      domain_name = "dlcs.io"
      origin_path = "/iiif-img/wellcome/8"
    },
    {
      origin_id   = "dlcs_images"
      domain_name = "dlcs.io"
      origin_path = "/iiif-img/wellcome/5"
    },
    {
      origin_id   = "dlcs_thumbs"
      domain_name = "dlcs.io"
      origin_path = "/thumbs/wellcome/5"
    },
    {
      origin_id   = "dlcs_av"
      domain_name = "dlcs.io"
      origin_path = "/iiif-av/wellcome/5"
    },
    {
      origin_id   = "dlcs_pdf"
      domain_name = "dlcs.io"
      origin_path = "/pdf/wellcome/pdf/5"
    },
    {
      origin_id   = "dlcs_file"
      domain_name = "dlcs.io"
      origin_path = "/file/wellcome/5"
    }
  ]

  stage_origins = [
    {
      origin_id : "dds"
      domain_name : "dds-stage.dlcs.io"
      origin_path : null
    },
    {
      origin_id : "iiif"
      domain_name : "iiif-stage.dlcs.io"
      origin_path : null
    },
    {
      origin_id : "loris"
      domain_name : "iiif-origin.wellcomecollection.org"
      origin_path : null
    },
    {
      origin_id : "dlcs"
      domain_name : "dlcs.io"
      origin_path : null
    },
    {
      origin_id   = "dlcs_wellcome_images"
      domain_name = "dlcs.io"
      origin_path = "/iiif-img/wellcome/8"
    },
    {
      origin_id   = "dlcs_images"
      domain_name = "dlcs.io"
      origin_path = "/iiif-img/wellcome/6"
    },
    {
      origin_id   = "dlcs_thumbs"
      domain_name = "dlcs.io"
      origin_path = "/thumbs/wellcome/6"
    },
    {
      origin_id   = "dlcs_av"
      domain_name = "dlcs.io"
      origin_path = "/iiif-av/wellcome/6"
    },
    {
      origin_id   = "dlcs_pdf"
      domain_name = "dlcs.io"
      origin_path = "/pdf/wellcome/pdf/6"
    },
    {
      origin_id   = "dlcs_file"
      domain_name = "dlcs.io"
      origin_path = "/file/wellcome/6"
    }
  ]

  test_origins = [
    {
      origin_id : "dds"
      domain_name : "dds-test.dlcs.io"
      origin_path : null
    },
    {
      origin_id : "iiif"
      domain_name : "iiif-test.dlcs.io"
      origin_path : null
    },
    {
      origin_id : "loris"
      domain_name : "iiif-origin.wellcomecollection.org"
      origin_path : null
    },
    {
      origin_id : "dlcs"
      domain_name : "dlcs.io"
      origin_path : null
    },
    {
      origin_id   = "dlcs_wellcome_images"
      domain_name = "dlcs.io"
      origin_path = "/iiif-img/wellcome/8"
    },
    {
      origin_id   = "dlcs_images"
      domain_name = "dlcs.io"
      origin_path = "/iiif-img/wellcome/6"
    },
    {
      origin_id   = "dlcs_thumbs"
      domain_name = "dlcs.io"
      origin_path = "/thumbs/wellcome/6"
    },
    {
      origin_id   = "dlcs_av"
      domain_name = "dlcs.io"
      origin_path = "/iiif-av/wellcome/6"
    },
    {
      origin_id   = "dlcs_pdf"
      domain_name = "dlcs.io"
      origin_path = "/pdf/wellcome/pdf/6"
    },
    {
      origin_id   = "dlcs_file"
      domain_name = "dlcs.io"
      origin_path = "/file/wellcome/6"
    }
  ]
}