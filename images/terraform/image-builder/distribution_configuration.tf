resource "aws_imagebuilder_distribution_configuration" "imagebuilder_distribution_configuration" {
  count = length(var.target_account_ids) > 0 ? 1 : 0
  name  = "${var.name}-distribution"

  distribution {
    region = var.aws_region
    ami_distribution_configuration {
      name               = "${var.ami_name}-{{ imagebuilder:buildDate }}"
      description        = var.ami_description
      target_account_ids = var.target_account_ids
      launch_permission {
        user_ids = var.target_account_ids
      }
      ami_tags = var.tags
    }
  }
  tags = var.tags
}