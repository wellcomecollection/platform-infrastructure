locals {
  reporting_elasticsearch_user_settings = <<-EOT
# Note that the syntax for user settings can change between major versions.
# You might need to update these user settings before performing a major version upgrade.
#
# Slack integration example (for version 5.0 and later)
# xpack.notification.slack:
#   account:
#     monitoring:
#       url: https://hooks.slack.com/services/T0A6BLEEA/B0A6D1PRD/XYZ123
#
# Slack integration example (for versions before 5.0)
# watcher.actions.slack.service:
#   account:
#     monitoring:
#       url: https://hooks.slack.com/services/T0A6BLEEA/B0A6D1PRD/XYZ123
#       message_defaults:
#        from: Watcher
#
# HipChat and PagerDuty integration are also supported. To learn more, see the documentation.
xpack:
  security:
    authc:
      realms:
        oidc:
          cloud-oidc:
            order: 2
            rp.client_id: "45e3080f-367d-4c9c-828b-77c1c422c2c4"
            rp.response_type: "code"
            rp.redirect_uri: "https://reporting.wellcomecollection.org/api/security/v1/oidc"
            op.issuer: "https://login.microsoftonline.com/3b7a675a-1fc8-4983-a100-cc52b7647737/v2.0"
            op.authorization_endpoint: "https://login.microsoftonline.com/3b7a675a-1fc8-4983-a100-cc52b7647737/oauth2/v2.0/authorize"
            op.token_endpoint: "https://login.microsoftonline.com/3b7a675a-1fc8-4983-a100-cc52b7647737/oauth2/v2.0/token"
            op.userinfo_endpoint: "https://graph.microsoft.com/oidc/userinfo"
            op.jwkset_path: "https://login.microsoftonline.com/common/discovery/v2.0/keys"
            claims.principal: email
            claims.groups: groups
EOT

  reporting_kibana_user_settings = <<-EOT
# Note that the syntax for user settings can change between major versions.
# You might need to update these user settings before performing a major version upgrade.
#
# Use OpenStreetMap for tiles:
# tilemap:
#   options.maxZoom: 18
#   url: http://a.tile.openstreetmap.org/{z}/{x}/{y}.png
#
# To learn more, see the documentation.

xpack.security.authc:
  providers:
    oidc.oidc1:
      order: 0
      realm: "cloud-oidc"
      description: "Log in with your Wellcome account"
    basic.basic1:
      order: 1
server.xsrf.allowlist: [/api/security/v1/oidc]
xpack.reporting.csv.maxSizeBytes: 104857600
xpack.reporting.roles.enabled: false
EOT

  reporting_apm_user_settings = {
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

resource "ec_deployment" "reporting" {
  name = "reporting"

  region                 = "eu-west-1"
  version                = "8.4.0"
  deployment_template_id = "aws-io-optimized"

  elasticsearch {
    ref_id = "elasticsearch"

    /*node_type_data = "aws.data.highio.i3"*/
    /*node_type_ml   = "aws.ml.m5"*/

    topology {
      zone_count = 3
      size       = "4g"
    }

    topology {
      size       = "1g"
      zone_count = 1
    }

    config {
      plugins = [
        "ingest-geoip",
        "ingest-user-agent",
      ]

      user_settings_yaml = local.reporting_elasticsearch_user_settings
    }
  }

  kibana {
    elasticsearch_cluster_ref_id = "elasticsearch"
    ref_id                       = "kibana"

    topology {
      zone_count = 1
      size       = "2g"
    }

    config {
      user_settings_yaml = local.reporting_kibana_user_settings
    }
  }
}

locals {
  reporting_elastic_id     = ec_deployment.reporting.elasticsearch[0].resource_id
  reporting_elastic_region = ec_deployment.reporting.elasticsearch[0].region

  reporting_kibana_id       = ec_deployment.reporting.kibana[0].resource_id
  reporting_kibana_region   = ec_deployment.reporting.kibana[0].region
  reporting_kibana_endpoint = "${local.reporting_kibana_id}.${local.reporting_kibana_region}.aws.found.io"

  reporting_elastic_username = ec_deployment.reporting.elasticsearch_username
  reporting_elastic_password = ec_deployment.reporting.elasticsearch_password

  # See https://www.elastic.co/guide/en/cloud/current/ec-traffic-filtering-vpc.html
  reporting_private_host = "${local.reporting_elastic_id}.vpce.${local.reporting_elastic_region}.aws.elastic-cloud.com"
  reporting_public_host  = "${local.reporting_elastic_id}.${local.reporting_elastic_region}.aws.found.io"
}

module "reporting_secrets" {
  source = "github.com/wellcomecollection/terraform-aws-secrets.git?ref=v1.3.0"

  key_value_map = {
    "elasticsearch/reporting/username"        = local.reporting_elastic_username
    "elasticsearch/reporting/password"        = local.reporting_elastic_password
    "elasticsearch/reporting/public_host"     = local.reporting_public_host
    "elasticsearch/reporting/private_host"    = local.reporting_private_host
    "elasticsearch/reporting/kibana_endpoint" = local.reporting_kibana_endpoint

    # Duplicated as this is what consumers currently expect
    # The above naming scheme is common to our other ES setups
    # So we have both for now
    "shared/reporting/es_host"         = local.reporting_public_host
    "shared/reporting/es_host_private" = local.reporting_private_host
  }
}
