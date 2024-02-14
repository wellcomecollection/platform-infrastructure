resource "aws_imagebuilder_image_pipeline" "imagebuilder_image_pipeline" {
  image_recipe_arn                 = aws_imagebuilder_image_recipe.imagebuilder_image_recipe.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.imagebuilder_infrastructure_configuration.arn
  distribution_configuration_arn   = null
  dynamic "schedule" {
    for_each = try(var.schedule_expression, tomap({}))
    content {
      schedule_expression                = schedule.key
      pipeline_execution_start_condition = schedule.value
    }
  }
  name = "${var.name}-pipeline"
  tags = var.tags
}