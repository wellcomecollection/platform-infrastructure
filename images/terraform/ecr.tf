module "ecr_jvm_container_lambda" {
  source = "./repo_pair"

  namespace   = local.namespace
  repo_name   = "jvm_container_lambda"
  description = "A base image for JVM-based Lambda functions"

  providers = {
    aws.ecr_public = aws.ecr_public
  }
}

module "ecr_fluentbit" {
  source = "./repo_pair"

  namespace   = local.namespace
  repo_name   = "fluentbit"
  description = "A fluentbit image for sending logs to Logstash"

  providers = {
    aws.ecr_public = aws.ecr_public
  }
}

module "ecr_nginx_experience" {
  source = "./repo_pair"

  namespace = local.namespace
  repo_name = "nginx_experience"

  description = "DEPRECATED: prefer nginx_frontend"

  providers = {
    aws.ecr_public = aws.ecr_public
  }
}

module "ecr_nginx_frontend" {
  source = "./repo_pair"

  namespace = local.namespace
  repo_name = "nginx_frontend"

  description = "An nginx image for reverse proxying applications with frontends"

  providers = {
    aws.ecr_public = aws.ecr_public
  }
}

module "ecr_nginx_frontend_identity" {
  source = "./repo_pair"

  namespace = local.namespace
  repo_name = "nginx_frontend_identity"

  description = "An nginx image for reverse proxying in the identity web app"

  providers = {
    aws.ecr_public = aws.ecr_public
  }
}

module "ecr_nginx_apigw" {
  source = "./repo_pair"

  namespace   = local.namespace
  repo_name   = "nginx_apigw"
  description = "An nginx image to run as a proxy between API Gateway and our app containers"

  providers = {
    aws.ecr_public = aws.ecr_public
  }
}

// Cross account access policies

module "nginx_apigw" {
  source = "./repo_policy"

  account_ids = local.account_ids
  repo_name   = module.ecr_nginx_apigw.private_repo_name
}

module "nginx_experience" {
  source = "./repo_policy"

  account_ids = local.account_ids
  repo_name   = module.ecr_nginx_experience.private_repo_name
}

module "nginx_frontend" {
  source = "./repo_policy"

  account_ids = local.account_ids
  repo_name   = module.ecr_nginx_frontend.private_repo_name
}

module "nginx_frontend_identity" {
  source = "./repo_policy"

  account_ids = local.account_ids
  repo_name   = module.ecr_nginx_frontend_identity.private_repo_name
}

module "fluentbit" {
  source = "./repo_policy"

  account_ids = local.account_ids
  repo_name   = module.ecr_fluentbit.private_repo_name
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
    "localstack/localstack",
    "nginx",
    "pyfound/black",
    "wellcome/flake8",
    "wellcome/sbt_wrapper",
    "wellcome/tox",
    "zenko/cloudserver",
  ]
}
