resource "aws_ecr_repository" "fluentbit" {
  name = "${local.namespace}/fluentbit"
}

resource "aws_ecr_repository" "nginx_experience" {
  name = "${local.namespace}/nginx_experience"
}

resource "aws_ecr_repository" "nginx_loris" {
  name = "${local.namespace}/nginx_loris"
}

resource "aws_ecr_repository" "nginx_grafana" {
  name = "${local.namespace}/nginx_grafana"
}

resource "aws_ecr_repository" "nginx_apigw" {
  name = "${local.namespace}/nginx_apigw"
}

// Cross account access policies

module "nginx_apigw" {
  source = "./repo_policy"

  account_ids = local.account_ids
  repo_name   = aws_ecr_repository.nginx_apigw.name
}

module "nginx_experience" {
  source = "./repo_policy"

  account_ids = local.account_ids
  repo_name   = aws_ecr_repository.nginx_experience.name
}

module "fluentbit" {
  source = "./repo_policy"

  account_ids = local.account_ids
  repo_name   = aws_ecr_repository.fluentbit.name
}

# In order to avoid docker hub rate limiting, we mirror some docker hub images
# see .../publish_mirrored_images.py for the script that copies images to these repos

resource "aws_ecr_repository" "mirrored_images" {
  for_each = toset(local.mirrored_images)

  name = each.key
}

module "mirrored_images_policy" {
  source   = "./repo_policy"
  for_each = toset(local.mirrored_images)

  account_ids = local.account_ids
  repo_name   = aws_ecr_repository.mirrored_images[each.key].name
}


locals {
  mirrored_images = [
    "amazon/aws-cli",
    "hashicorp/terraform",
    "localstack/localstack",
    "nginx",
    "node",
    "peopleperhour/dynamodb",
    "python",
    "rodolpheche/wiremock",
    "s12v/elasticmq",
    "scality/s3server",
    "wellcome/build_test_python",
    "wellcome/fake-sns",
    "wellcome/flake8",
    "wellcome/format_python",
    "wellcome/format_python",
    "wellcome/image_builder",
    "wellcome/publish_lambda",
    "wellcome/sbt_wrapper",
    "wellcome/scalafmt",
    "wellcome/tox",
    "wellcome/typesafe_config_base",
    "wellcome/weco-deploy",
    "zenko/cloudserver",
  ]
}
