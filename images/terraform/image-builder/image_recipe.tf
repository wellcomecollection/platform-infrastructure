resource "aws_imagebuilder_image_recipe" "imagebuilder_image_recipe" {
  name         = "${var.name}-image-recipe"
  parent_image = var.source_ami_id
  version      = var.recipe_version

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