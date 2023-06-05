locals {
  container_port  = 3000
  container_name  = "app"
  efs_volume_name = "efs"
}

module "log_router_container" {
  source = "github.com/wellcomecollection/terraform-aws-ecs-service//modules/firelens?ref=v3.13.2"

  namespace                = var.namespace
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

  environment = {
    GF_AUTH_ANONYMOUS_ENABLED  = var.grafana_anonymous_enabled
    GF_AUTH_ANONYMOUS_ORG_ROLE = var.grafana_anonymous_role
    GF_SECURITY_ADMIN_USER     = var.grafana_admin_user
    GF_SECURITY_ADMIN_PASSWORD = var.grafana_admin_password
  }

  port_mappings = [{
    containerPort = local.container_port
    hostPort      = local.container_port
    protocol      = "tcp"
  }]

  log_configuration = module.log_router_container.container_log_configuration
}

module "task_definition" {
  source = "github.com/wellcomecollection/terraform-aws-ecs-service//modules/task_definition?ref=v3.13.2"

  task_name    = var.namespace
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

  service_name        = var.namespace
  cluster_arn         = var.cluster_arn
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
