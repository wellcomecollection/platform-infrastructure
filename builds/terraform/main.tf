module "catalogue_repo" {
  source    = "./platform"
  repo_name = "catalogue"

  sbt_releases_bucket_arn = aws_s3_bucket.releases.arn
  infra_bucket_arn        = local.infra_bucket_arn

  publish_topics = [
    aws_sns_topic.ecr_pushes.arn,
    aws_sns_topic.lambda_pushes.arn,
  ]

  assumable_ci_roles = [
    local.platform_read_only_role_arn,
    local.ci_role_arn["catalogue"]
  ]

  providers = {
    aws    = aws.platform
    github = github.collection
  }
}

module "storage_repo" {
  source    = "./platform"
  repo_name = "storage-service"

  sbt_releases_bucket_arn = aws_s3_bucket.releases.arn
  infra_bucket_arn        = local.infra_bucket_arn

  publish_topics = [
    aws_sns_topic.ecr_pushes.arn,
    aws_sns_topic.lambda_pushes.arn,
  ]

  assumable_ci_roles = [
    local.platform_read_only_role_arn,
    local.ci_role_arn["storage"]
  ]

  providers = {
    aws    = aws.storage
    github = github.collection
  }
}

module "stacks_service_repo" {
  source    = "./platform"
  repo_name = "stacks-service"

  sbt_releases_bucket_arn = aws_s3_bucket.releases.arn
  infra_bucket_arn        = local.infra_bucket_arn

  publish_topics = [
    aws_sns_topic.ecr_pushes.arn,
    aws_sns_topic.lambda_pushes.arn,
  ]

  assumable_ci_roles = [
    local.platform_read_only_role_arn,
    local.ci_role_arn["catalogue"]
  ]

  providers = {
    aws    = aws.catalogue
    github = github.collection
  }
}

module "archivematica_infrastructure_repo" {
  source    = "./platform"
  repo_name = "archivematica-infrastructure"

  sbt_releases_bucket_arn = aws_s3_bucket.releases.arn
  infra_bucket_arn        = local.infra_bucket_arn

  publish_topics = [
    aws_sns_topic.ecr_pushes.arn,
    aws_sns_topic.lambda_pushes.arn,
  ]

  assumable_ci_roles = [
    local.platform_read_only_role_arn,
    local.ci_role_arn["workflow"]
  ]

  providers = {
    aws    = aws.workflow
    github = github.collection
  }
}

module "loris_infrastructure_repo" {
  source    = "./platform"
  repo_name = "loris-infrastructure"

  sbt_releases_bucket_arn = aws_s3_bucket.releases.arn
  infra_bucket_arn        = local.infra_bucket_arn

  publish_topics = [
    aws_sns_topic.ecr_pushes.arn,
    aws_sns_topic.lambda_pushes.arn,
  ]

  assumable_ci_roles = [
    local.platform_read_only_role_arn,
    local.ci_role_arn["platform"]
  ]

  providers = {
    aws    = aws.platform
    github = github.collection
  }
}

module "scala_libs" {
  source = "./scala_library"

  name = "libs"
  lib_names = [
    "json",
    "storage",
    "monitoring",
    "messaging",
    "fixtures",
    "typesafe_app"
  ]

  bucket_arn = aws_s3_bucket.releases.arn

  assumable_ci_roles = [
    local.platform_read_only_role_arn,
    local.ci_role_arn["platform"]
  ]

  providers = {
    aws    = aws.platform
    github = github.collection
  }
}

module "scala_json" {
  source = "./scala_library"

  name = "json"
  lib_names = [
  "json"]
  bucket_arn = aws_s3_bucket.releases.arn

  assumable_ci_roles = [
    local.platform_read_only_role_arn,
    local.ci_role_arn["platform"]
  ]

  providers = {
    aws    = aws.platform
    github = github.collection
  }
}

module "scala_storage" {
  source = "./scala_library"

  name = "storage"
  lib_names = [
  "storage"]
  bucket_arn = aws_s3_bucket.releases.arn

  assumable_ci_roles = [
    local.platform_read_only_role_arn,
    local.ci_role_arn["platform"]
  ]

  providers = {
    aws    = aws.platform
    github = github.collection
  }
}

module "scala_monitoring" {
  source = "./scala_library"

  name = "monitoring"
  lib_names = [
  "monitoring"]
  bucket_arn = aws_s3_bucket.releases.arn

  assumable_ci_roles = [
    local.platform_read_only_role_arn,
    local.ci_role_arn["platform"]
  ]

  providers = {
    aws    = aws.platform
    github = github.collection
  }
}

module "scala_messaging" {
  source = "./scala_library"

  name = "messaging"
  lib_names = [
  "messaging"]
  bucket_arn = aws_s3_bucket.releases.arn

  assumable_ci_roles = [
    local.platform_read_only_role_arn,
    local.ci_role_arn["platform"]
  ]

  providers = {
    aws    = aws.platform
    github = github.collection
  }
}

module "scala_fixtures" {
  source = "./scala_library"

  name = "fixtures"
  lib_names = [
  "fixtures"]
  bucket_arn = aws_s3_bucket.releases.arn

  assumable_ci_roles = [
    local.platform_read_only_role_arn,
    local.ci_role_arn["platform"]
  ]

  providers = {
    aws    = aws.platform
    github = github.collection
  }
}

module "scala_typesafe" {
  source = "./scala_library"

  name = "typesafe-app"
  lib_names = [
  "typesafe-app"]
  repo_name  = "wellcome-typesafe-app"
  bucket_arn = aws_s3_bucket.releases.arn

  assumable_ci_roles = [
    local.platform_read_only_role_arn,
    local.ci_role_arn["platform"]
  ]

  providers = {
    aws    = aws.platform
    github = github.collection
  }
}

module "scala_sierra" {
  source = "./scala_library"

  name = "sierra-streams-source"
  lib_names = [
  "sierra-streams-source"]
  repo_name = "sierra-streams-source"

  bucket_arn = aws_s3_bucket.releases.arn

  assumable_ci_roles = [
    local.platform_read_only_role_arn,
    local.ci_role_arn["platform"]
  ]

  providers = {
    aws    = aws.platform
    github = github.collection
  }
}
