resource "aws_imagebuilder_image_recipe" "imagebuilder_image_recipe" {
  name         = "${var.name}-image-recipe"
  parent_image = var.source_ami_id
  version      = var.recipe_version
  
  # it seems there is a bug on checkov for check CKV_AWS_200, even supressing it doesn't help, had to add the below block_device_mapping to pass
#   block_device_mapping {
#     device_name = "/dev/xvdb"

#     ebs {
#       delete_on_termination = true
#       volume_size           = var.recipe_volume_size
#       volume_type           = var.recipe_volume_type
#       encrypted             = true
#     }
#   }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "component" {
    for_each = var.build_component_arn
    content {
      component_arn = component.value
    }
  }

  tags = var.tags
}