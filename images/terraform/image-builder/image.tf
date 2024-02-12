resource "aws_imagebuilder_image" "imagebuilder_image" {
  count                            = 1
  image_recipe_arn                 = aws_imagebuilder_image_recipe.imagebuilder_image_recipe.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.imagebuilder_infrastructure_configuration.arn
  distribution_configuration_arn   = try(aws_imagebuilder_distribution_configuration.imagebuilder_distribution_configuration[count.index].arn, null)

  tags = var.tags

  timeouts {
    create = var.timeout
  }
}