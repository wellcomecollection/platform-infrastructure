resource "aws_ecr_repository_policy" "cross_account_policy" {
  repository = var.repo_name
  policy = data.aws_iam_policy_document.get_images.json
}

data "aws_iam_policy_document" "get_images" {
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]

    principals {
      identifiers = local.identifiers
      type = "AWS"
    }
  }
}
locals {
  identifiers = [for id in var.account_ids : "arn:aws:iam::${id}:root"]
}