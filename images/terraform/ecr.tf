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
  repo_name  = aws_ecr_repository.nginx_apigw.name
}

module "nginx_experience" {
  source = "./repo_policy"

  account_ids = local.account_ids
  repo_name  = aws_ecr_repository.nginx_experience.name
}

module "fluentbit" {
  source = "./repo_policy"

  account_ids = local.account_ids
  repo_name  = aws_ecr_repository.fluentbit.name
}