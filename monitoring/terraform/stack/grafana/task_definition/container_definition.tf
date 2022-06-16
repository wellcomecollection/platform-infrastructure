data "template_file" "container_definition" {
  template = "${file("${path.module}/task_definition.json.tpl")}"

  vars = {
    use_aws_logs = var.use_awslogs

    log_group_region = var.aws_region
    log_group_name   = aws_cloudwatch_log_group.log_group.name
    log_group_prefix = "ecs"

    container_image = var.container_image
    container_name  = var.container_name

    secrets = module.secrets.env_vars_string

    environment_vars = jsonencode([
      for key in sort(keys(var.env_vars)) :
      {
        name  = key
        value = lookup(var.env_vars, key)
      }
    ])

    command = jsonencode(var.command)

    cpu    = var.cpu
    memory = var.memory

    mount_points = jsonencode(var.mount_points)

    user = var.user

    port_mappings_defined = var.container_port == "" ? false : true

    port_mappings = jsonencode([
      {
        "containerPort" = var.container_port,

        # TODO: I think we can safely drop both these arguments.
        "hostPort" = var.container_port,
        "protocol" = "tcp"
      }
    ])
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "ecs/${var.task_name}"

  retention_in_days = 7
}

module "secrets" {
  source = "./secrets"

  secret_env_vars = var.secret_env_vars

  execution_role_name = module.task_role.task_execution_role_name
}
