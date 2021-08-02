resource "aws_ecs_service" "service" {
  name            = local.service_name
  cluster         = var.cluster_arn
  task_definition = var.task_definition_arn
  desired_count   = var.desired_task_count

  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.service_discovery.arn
  }

  # We can't specify both a launch type and a capacity provider strategy.
  launch_type = var.use_fargate_spot ? null : var.launch_type

  dynamic "capacity_provider_strategy" {
    for_each = var.use_fargate_spot ? [{}] : []

    content {
      capacity_provider = "FARGATE_SPOT"
      weight            = 1
    }
  }

  # This is a slightly obtuse way to make this block conditional.
  # They should only be created if this task definition is using EBS volume
  # mounts; otherwise they should be ignored.
  #
  # This is a kludge around Terraform's "dynamic blocks".
  # See https://www.terraform.io/docs/configuration/expressions.html#dynamic-blocks
  #
  # There's an open feature request on the Terraform repo to add syntactic
  # sugar for this sort of conditional block.  If that ever arises, we should
  # use that instead.  See https://github.com/hashicorp/terraform/issues/21512
  #
  # We condition on container_port rather than target_group_arn, because this should
  # be a static string declared immediately.  If you use target_group_arn, and
  # when you create the module you fill it in dynamically, e..g
  #
  #     target_group_arn = aws_lb_target_group.tcp.arn
  #
  # Terraform can't work out if it's non-empty, and gets upset trying to plan.
  dynamic "load_balancer" {
    for_each = var.container_port == "" ? [] : [{}]

    content {
      target_group_arn = var.target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  lifecycle {
    # If you try to apply tags to our Grafana service, you get an error:
    #
    #     InvalidParameterException: Long arn format must be used for tagging operations
    #
    # This is because AWS have changed the ARN format on ECS clusters, and
    # you need to migrate to the new format to apply tags.  Our Grafana service
    # is very old, predates this change, and has never been migrated.
    #
    # We should migrate it… eventually… but I don't fancy doing it right now and
    # potentially breaking Grafana.
    #
    # See https://github.com/hashicorp/terraform-provider-aws/issues/7373#issuecomment-458810667
    #
    # TODO: Sort out the tagging on this service.
    ignore_changes = [
      tags,
    ]
  }
}
