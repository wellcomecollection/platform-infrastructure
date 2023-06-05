locals {
  container_port  = 3000
  container_name  = "app"
  efs_volume_name = "efs"

  grafana_env = {
    GF_SERVER_DOMAIN              = var.domain
    GF_SERVER_ROOT_URL            = "https://${var.domain}/"
    GF_SECURITY_ADMIN_USER        = "admin"
    GF_USERS_AUTO_ASSIGN_ORG_ROLE = "Editor"
    # See https://grafana.com/docs/grafana/v9.3/setup-grafana/configure-security/configure-authentication/azuread/#enable-azure-ad-oauth-in-grafana
    GF_AUTH_AZUREAD_NAME                       = "Azure AD"
    GF_AUTH_AZUREAD_SCOPES                     = "openid email profile offline_access"
    GF_AUTH_AZUREAD_ENABLED                    = true
    GF_AUTH_AZUREAD_ALLOW_SIGN_UP              = true
    GF_AUTH_AZUREAD_AUTO_LOGIN                 = false
    GF_AUTH_AZUREAD_ROLE_ATTRIBUTE_STRICT      = false
    GF_AUTH_AZUREAD_ALLOW_ASSIGN_GRAFANA_ADMIN = false
    GF_AUTH_AZUREAD_USE_PKCE                   = true
  }
  grafana_secrets = {
    GF_SECURITY_ADMIN_PASSWORD    = "monitoring/${var.namespace}/grafana/admin_password"
    GF_AUTH_AZUREAD_CLIENT_ID     = "monitoring/${var.namespace}/grafana/azure_application_id"
    GF_AUTH_AZUREAD_CLIENT_SECRET = "monitoring/${var.namespace}/grafana/azure_client_secret"
    GF_AUTH_AZUREAD_AUTH_URL      = "monitoring/${var.namespace}/grafana/azure_auth_url"
    GF_AUTH_AZUREAD_TOKEN_URL     = "monitoring/${var.namespace}/grafana/azure_token_url"
  }
}

module "log_router_container" {
  source = "github.com/wellcomecollection/terraform-aws-ecs-service//modules/firelens?ref=v3.13.2"

  namespace                = "${var.namespace}-grafana"
  use_privatelink_endpoint = true
}

module "log_router_container_secrets_permissions" {
  source    = "github.com/wellcomecollection/terraform-aws-ecs-service//modules/secrets?ref=v3.13.2"
  secrets   = module.log_router_container.shared_secrets_logging
  role_name = module.task_definition.task_execution_role_name
}

module "grafana_app_container" {
  source = "github.com/wellcomecollection/terraform-aws-ecs-service//modules/container_definition?ref=v3.13.2"

  name  = "app"
  image = "grafana/grafana-oss:${var.grafana_version}"

  mount_points = [{
    containerPath = "/var/lib/grafana"
    sourceVolume  = local.efs_volume_name
  }]

  environment = local.grafana_env
  secrets     = local.grafana_secrets

  port_mappings = [{
    containerPort = local.container_port
    hostPort      = local.container_port
    protocol      = "tcp"
  }]

  log_configuration = module.log_router_container.container_log_configuration
}

module "app_permissions" {
  source    = "git::github.com/wellcomecollection/terraform-aws-ecs-service.git//modules/secrets?ref=v3.13.2"
  secrets   = local.grafana_secrets
  role_name = module.task_definition.task_execution_role_name
}

module "task_definition" {
  source = "github.com/wellcomecollection/terraform-aws-ecs-service//modules/task_definition?ref=v3.13.2"

  task_name    = "${var.namespace}-grafana"
  launch_types = ["FARGATE"]
  cpu          = 256
  memory       = 512

  container_definitions = [
    module.grafana_app_container.container_definition,
    module.log_router_container.container_definition
  ]

  efs_volumes = [{
    name           = local.efs_volume_name
    file_system_id = var.efs_id
    root_directory = "/grafana"
  }]
}

module "service" {
  source = "github.com/wellcomecollection/terraform-aws-ecs-service//modules/service?ref=v3.13.2"

  service_name        = "${var.namespace}-grafana"
  cluster_arn         = aws_ecs_cluster.cluster.arn
  task_definition_arn = module.task_definition.arn

  container_name = local.container_name
  container_port = local.container_port

  target_group_arn = aws_alb_target_group.grafana_ecs_service.arn
  subnets          = var.private_subnets
  security_group_ids = [
    aws_security_group.service_lb_security_group.id,
    aws_security_group.service_egress_security_group.id,
    var.efs_security_group_id,
    var.ec_privatelink_security_group_id
  ]
}
