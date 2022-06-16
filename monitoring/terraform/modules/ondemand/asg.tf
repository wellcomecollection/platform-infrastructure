resource "aws_cloudformation_stack" "ecs_asg" {
  name          = var.name
  template_body = templatefile(
    "${path.module}/asg.json.template",
    {
      launch_config_name  = aws_launch_configuration.launch_config.name
      vpc_zone_identifier = jsonencode(var.subnet_list)
      asg_min_size        = 1
      asg_desired_size    = 1
      asg_max_size        = 2
      asg_name            = var.name
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
