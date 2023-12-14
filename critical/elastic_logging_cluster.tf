locals {
  logging_elasticsearch_user_settings = {
    xpack : {
      security : {
        authc : {
          realms : {
            oidc : {
              cloud-oidc : {
                order : 2
                "rp.client_id" : local.client_id
                "rp.response_type" : "code"
                "rp.redirect_uri" : "https://logging.wellcomecollection.org/api/security/v1/oidc"
                "op.issuer" : "https://login.microsoftonline.com/${local.tenant_id}/v2.0"
                "op.authorization_endpoint" : "https://login.microsoftonline.com/${local.tenant_id}/oauth2/v2.0/authorize"
                "op.token_endpoint" : "https://login.microsoftonline.com/${local.tenant_id}/oauth2/v2.0/token"
                "op.userinfo_endpoint" : "https://graph.microsoft.com/oidc/userinfo"
                "op.jwkset_path" : "https://login.microsoftonline.com/${local.tenant_id}/discovery/v2.0/keys"
                "claims.principal" : "sub"
                "claims.groups" : "groups"
              }
            }
          }
        }
      }
    }
  }

  logging_kibana_user_settings = {
    "xpack.security.authc.providers" : {
      "oidc.cloud-oidc" : {
        order : 0
        realm : "cloud-oidc"
        description : "Log in with Azure"
      }
      "basic.basic1" : {
        order : 1
      }
    }
  }

  logging_apm_user_settings = {
    "apm-server" : {
      # RUM = Real-User Monitoring
      rum : {
        enabled : true
      }
    }
  }
}

# IMPORTANT: When deploying fresh you will need to set the following key in Elasticsearch keystore:
# xpack.security.authc.realms.oidc.cloud-oidc.rp.client_secret
# This should be set to the value of the client_secret found in the Azure AD registered application.
# It can be set through the Elastic Cloud console.

resource "ec_deployment" "logging" {
  name = "logging"

  region                 = "eu-west-1"
  version                = "8.4.0"
  deployment_template_id = "aws-io-optimized-v2"

  traffic_filter = [
    ec_deployment_traffic_filter.public_internet.id,
    module.platform_privatelink.traffic_filter_vpce_id,
    module.catalogue_privatelink.traffic_filter_vpce_id,
    module.storage_privatelink.traffic_filter_vpce_id,
    module.experience_privatelink.traffic_filter_vpce_id,
    module.digirati_privatelink.traffic_filter_vpce_id,
    module.identity_prod_privatelink.traffic_filter_vpce_id,
    module.identity_stage_privatelink.traffic_filter_vpce_id,
    module.workflow_prod_privatelink.traffic_filter_vpce_id,
    module.workflow_stage_privatelink.traffic_filter_vpce_id,
    module.monitoring_privatelink.traffic_filter_vpce_id
  ]

  elasticsearch {
    topology {
      id         = "hot_content"
      zone_count = 3
      size       = "8g"
    }

    config {
      user_settings_yaml = yamlencode(local.logging_elasticsearch_user_settings)
    }
  }

  kibana {
    topology {
      zone_count = 1
      size       = "2g"
    }

    config {
      user_settings_yaml = yamlencode(local.logging_kibana_user_settings)
    }
  }

  apm {
    topology {
      size       = "1g"
      zone_count = 1
    }

    config {
      user_settings_yaml = yamlencode(local.logging_apm_user_settings)
    }
  }
}

locals {
  logging_elastic_id     = ec_deployment.logging.elasticsearch[0].resource_id
  logging_elastic_region = ec_deployment.logging.elasticsearch[0].region

  logging_kibana_id       = ec_deployment.logging.kibana[0].resource_id
  logging_kibana_region   = ec_deployment.logging.kibana[0].region
  logging_kibana_endpoint = "${local.logging_kibana_id}.${local.logging_kibana_region}.aws.found.io"

  logging_elastic_username = ec_deployment.logging.elasticsearch_username
  logging_elastic_password = ec_deployment.logging.elasticsearch_password

  # See https://www.elastic.co/guide/en/cloud/current/ec-traffic-filtering-vpc.html
  logging_private_host = "${local.logging_elastic_id}.vpce.${local.logging_elastic_region}.aws.elastic-cloud.com"
  logging_public_host  = "${local.logging_elastic_id}.${local.logging_elastic_region}.aws.found.io"

  logging_apm_server_url = ec_deployment.logging.apm[0].https_endpoint
  logging_apm_secret     = ec_deployment.logging.apm_secret_token

  logging_forwarder_api_key = elasticstack_elasticsearch_security_api_key.log_forwarder.encoded
}

module "host_secrets" {
  source = "github.com/wellcomecollection/terraform-aws-secrets.git?ref=v1.3.0"

  key_value_map = {
    "elasticsearch/logging/username"        = local.logging_elastic_username
    "elasticsearch/logging/password"        = local.logging_elastic_password
    "elasticsearch/logging/public_host"     = local.logging_public_host
    "elasticsearch/logging/private_host"    = local.logging_private_host
    "elasticsearch/logging/kibana_endpoint" = local.logging_kibana_endpoint
    "elasticsearch/logging/apm_server_url"  = local.logging_apm_server_url
    "elasticsearch/logging/apm_secret"      = local.logging_apm_secret

    "elasticsearch/logging/forwarder/api_key" = local.logging_forwarder_api_key

    # Duplicated as this is what consumers currently expect
    # The above naming scheme is common to our other ES setups
    # So we have both for now
    "shared/logging/es_host"         = local.logging_public_host
    "shared/logging/es_host_private" = local.logging_private_host
  }
}

# Create xpack config
resource "elasticstack_elasticsearch_security_role_mapping" "logging" {
  provider = elasticstack.logging

  name    = "cloud_oidc_to_kibana"
  enabled = true

  roles = [
    "kibana_admin",
    "reporting_user",
    "logging_read_only",
    "apm_user",
    "monitoring_user",
  ]
  rules = jsonencode({
    field = {
      "realm.name" = "cloud-oidc"
    }
  })
  metadata = jsonencode({ version = 1 })
}

// These are custom ILM policies which we attach to the @custom component templates as documented at
// https://www.elastic.co/guide/en/apm/guide/current/ilm-how-to.html
// The rollover/deletion values are chosen with the intention of avoiding the cluster storage filling up
// and may need modifying in future.
resource "elasticstack_elasticsearch_index_lifecycle" "apm_traces" {
  provider = elasticstack.logging
  name     = "weco-traces-apm"

  hot {
    rollover {
      max_size = "50gb"
      max_age  = "30d"
    }
  }

  delete {
    min_age = "10d"
  }
}

resource "elasticstack_elasticsearch_index_lifecycle" "apm_traces_rum" {
  provider = elasticstack.logging
  name     = "weco-traces-apm-rum"

  hot {
    rollover {
      max_size = "50gb"
      max_age  = "30d"
    }
  }

  delete {
    min_age = "10d"
  }
}

resource "elasticstack_elasticsearch_component_template" "apm_traces_managed_custom" {
  provider = elasticstack.logging
  name     = "traces-apm@custom"

  template {
    settings = jsonencode({
      lifecycle = {
        name = elasticstack_elasticsearch_index_lifecycle.apm_traces.name
      }
    })
  }

  metadata = jsonencode(
    {
      managed    = true
      managed_by = "fleet"
      package = {
        name = "apm"
      }
    }
  )
}

resource "elasticstack_elasticsearch_component_template" "apm_traces_rum_managed_custom" {
  provider = elasticstack.logging
  name     = "traces-apm.rum@custom"

  template {
    settings = jsonencode({
      lifecycle = {
        name = elasticstack_elasticsearch_index_lifecycle.apm_traces_rum.name
      }
    })
  }

  metadata = jsonencode(
    {
      managed    = true
      managed_by = "fleet"
      package = {
        name = "apm"
      }
    }
  )
}
