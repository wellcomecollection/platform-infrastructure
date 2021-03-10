resource "ec_deployment" "logging" {
  name = "logging"

  region                 = "eu-west-1"
  version                = "7.11.2"
  deployment_template_id = "aws-io-optimized-v2"

  traffic_filter = [
    ec_deployment_traffic_filter.public_internet.id,
    module.platform_privatelink.traffic_filter_vpce_id,
    module.catalogue_privatelink.traffic_filter_vpce_id,
  ]

  elasticsearch {
    topology {
      zone_count = 3
      size       = "8g"
    }

    config {
      user_settings_yaml = templatefile(
        "${path.module}/logging_elasticsearch.yml",
        {
          client_id = "2e5c6629-558e-4202-b802-f66674acf939",
          tenant_id = "3b7a675a-1fc8-4983-a100-cc52b7647737"
        }
      )
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
  catalogue_elastic_id     = ec_deployment.logging.elasticsearch[0].resource_id
  catalogue_elastic_region = ec_deployment.logging.elasticsearch[0].region
}

module "host_secrets" {
  source = "./modules/secrets/secret"

  key_value_map = {
    "shared/logging/es_host" = "${local.catalogue_elastic_id}.vpce.${local.catalogue_elastic_region}.aws.elastic-cloud.com"
  }
}
