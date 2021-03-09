locals {
  prod_origins = [
    {
      origin_id : "dashboard"
      domain_name : "dash-stage.wellcomecollection.digirati.io"
      origin_path : null
    },
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
    // We have manually enable Origin Shield for this origin
    // in order to increase the cache hit ratio.
    // See: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/origin-shield.html
    // It cannot be enabled with Terraform at time of writing.
    // See: https://github.com/hashicorp/terraform-provider-aws/issues/15752
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
    },
    {
      origin_id   = "pdf_cover"
      domain_name = "pdf.wellcomecollection.digirati.io"
      origin_path = null
    }
  ]

  stage_origins = [
    {
      origin_id : "dashboard"
      domain_name : "dash-stage.wellcomecollection.digirati.io"
      origin_path : null
    },
    {
      origin_id : "iiif"
      domain_name : "dds-stage.wellcomecollection.digirati.io"
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
    },
    {
      origin_id   = "pdf_cover"
      domain_name = "pdf-stage.wellcomecollection.digirati.io"
      origin_path = null
    }
  ]

  test_origins = [
    {
      origin_id : "dashboard"
      domain_name : "dash-test.wellcomecollection.digirati.io"
      origin_path : null
    },
    {
      origin_id : "iiif"
      domain_name : "dds-test.wellcomecollection.digirati.io"
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
    },
    {
      origin_id   = "pdf_cover"
      domain_name = "pdf-stage.wellcomecollection.digirati.io"
      origin_path = null
    }
  ]
}