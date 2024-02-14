resource "aws_imagebuilder_infrastructure_configuration" "imagebuilder_infrastructure_configuration" {
  instance_profile_name = aws_iam_instance_profile.iam_instance_profile.name
  instance_types        = var.instance_types

  name               = "${var.name}-infrastructure-configuration"
  security_group_ids = [aws_security_group.security_group.id]
  subnet_id          = var.subnet_id

  terminate_instance_on_failure = var.terminate_on_failure
  resource_tags                 = var.tags
  tags                          = var.tags
}