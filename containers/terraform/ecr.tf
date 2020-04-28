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

// storage

module "storage_repo_policy_nginx_apigw" {
  source = "./repo_policy"

  account_id = local.storage_account_id
  repo_name  = aws_ecr_repository.nginx_apigw.name
}

module "storage_repo_policy_fluentbit" {
  source = "./repo_policy"

  account_id = local.storage_account_id
  repo_name  = aws_ecr_repository.fluentbit.name
}

// experience

module "experience_repo_policy_nginx_experience" {
  source = "./repo_policy"

  account_id = local.experience_account_id
  repo_name  = aws_ecr_repository.nginx_experience.name
}

module "experience_repo_policy_fluentbit" {
  source = "./repo_policy"

  account_id = local.experience_account_id
  repo_name  = aws_ecr_repository.fluentbit.name
}

// catalogue

module "catalogue_repo_policy_nginx_apigw" {
  source = "./repo_policy"

  account_id = local.catalogue_account_id
  repo_name  = aws_ecr_repository.nginx_apigw.name
}

module "catalogue_repo_policy_fluentbit" {
  source = "./repo_policy"

  account_id = local.catalogue_account_id
  repo_name  = aws_ecr_repository.fluentbit.name
}
