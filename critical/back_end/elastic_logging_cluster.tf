resource "ec_deployment" "logging" {
  name = "logging-delta"

  region                 = "eu-west-1"
  version                = "7.11.2"
  deployment_template_id = "aws-io-optimized-v2"

  traffic_filter = [
    ec_deployment_traffic_filter.public_internet.id,
    module.platform_privatelink.traffic_filter_vpce_id,
    module.catalogue_privatelink.traffic_filter_vpce_id,
    module.storage_privatelink.traffic_filter_vpce_id,
    module.experience_privatelink.traffic_filter_vpce_id,
    module.digirati_privatelink.traffic_filter_vpce_id,
    module.identity_privatelink.traffic_filter_vpce_id,
    module.workflow_prod_privatelink.traffic_filter_vpce_id,
    module.workflow_stage_privatelink.traffic_filter_vpce_id,
  ]

  elasticsearch {
    topology {
      zone_count = 3
      size       = "8g"
    }
  }

  kibana {
    topology {
      zone_count = 1
      size       = "2g"
    }

    config {
      user_settings_yaml = file("${path.module}/kibana.yml")
    }
  }

  apm {
    topology {
      size       = "0.5g"
      zone_count = 1
    }
  }
}

locals {
  logging_elastic_id     = ec_deployment.logging.elasticsearch[0].resource_id
  logging_elastic_region = ec_deployment.logging.elasticsearch[0].region

  logging_kibana_id       = ec_deployment.logging.kibana[0].resource_id
  logging_kibana_region   = ec_deployment.logging.kibana[0].region
  logging_kibana_endpoint = "${local.logging_kibana_id}.${local.logging_kibana_region}.aws.found.io"
}

module "host_secrets" {
  source = "./modules/secrets/secret"

  key_value_map = {
    "shared/logging/es_host" = "${local.logging_elastic_id}.${local.logging_elastic_region}.aws.found.io"

    # See https://www.elastic.co/guide/en/cloud/current/ec-traffic-filtering-vpc.html
    "shared/logging/es_host_private" = "${local.logging_elastic_id}.vpce.${local.logging_elastic_region}.aws.elastic-cloud.com"
  }
}
