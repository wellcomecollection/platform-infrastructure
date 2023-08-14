resource "elasticstack_elasticsearch_security_user" "firelens_client" {
  provider = elasticstack.logging

  username = "firelens_client"
  password = random_password.firelens_client_password.result
  roles    = [elasticstack_elasticsearch_security_role.firelens_client.name]
}

resource "elasticstack_elasticsearch_security_role" "firelens_client" {
  provider = elasticstack.logging

  name    = "firelens_client"
  cluster = []

  indices {
    # The "firelens-*" pattern is legacy, can be removed if we are sure all services
    # are using new versions of the logging sidecar that are pointed at service-logs-firelens
    names      = [
      "firelens-*",
      "service-logs-*",
      module.firelens_service_log_data_stream.name
    ]

    privileges = ["all"]
  }
}

resource "random_password" "firelens_client_password" {
  length = 15
}

module "firelens_secrets" {
  source = "github.com/wellcomecollection/terraform-aws-secrets.git?ref=v1.3.0"

  key_value_map = {
    "shared/logging/es_user"                   = elasticstack_elasticsearch_security_user.firelens_client.username
    "shared/logging/es_pass"                   = elasticstack_elasticsearch_security_user.firelens_client.password
    "shared/logging/firelens_data_stream_name" = module.firelens_service_log_data_stream.name
  }
}

module "firelens_service_log_data_stream" {
  source = "./modules/elasticsearch_data_stream"
  providers = {
    elasticstack = elasticstack.logging
  }

  stream_name            = "service-logs-firelens"
  index_rollover_max_age = "1d"
  index_delete_after     = "30d"
}
