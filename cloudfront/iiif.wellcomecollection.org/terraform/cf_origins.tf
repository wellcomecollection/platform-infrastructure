locals {
  environments = {
    test : {
      dds_domain : "dds-test.dlcs.io"
      iiif_domain : "iiif-test.dlcs.io"
      loris_domain : "iiif-origin.wellcomecollection.org"
      dlcs_domain : "dlcs.io"
    }
    stage : {
      dds_domain : "dds-stage.dlcs.io"
      iiif_domain : "iiif-stage.dlcs.io"
      loris_domain : "iiif-origin.wellcomecollection.org"
      dlcs_domain : "dlcs.io"
    }
    prod : {
      dds_domain : "dds.dlcs.io"
      iiif_domain : "iiif.dlcs.io"
      loris_domain : "iiif-origin.wellcomecollection.org"
      dlcs_domain : "dlcs.io"
    }
  }

  origins = {
  for k,v in local.environments:
  k => [
    {
      origin_name : "dds"
      domain_name : v["dds_domain"]
      origin_path : null
    },
    {
      origin_name : "dlcs"
      domain_name: v["dlcs_domain"]
      origin_path : null
    },
    {
      origin_name : "loris"
      domain_name: v["loris_domain"]
      origin_path : null
    },
    {
      origin_name : "iiif"
      domain_name: v["iiif_domain"]
      origin_path : null
    },
    {
      origin_name = "dlcs_space_8"
      domain_name = v["dlcs_domain"]
      origin_path = "/iiif-img/wellcome/8"
    }
  ]
  }
}