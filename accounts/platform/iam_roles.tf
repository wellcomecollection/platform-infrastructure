# Developer S3 Scala library access

resource "aws_iam_role" "s3_scala_releases_read" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = [local.aws_principal]
      type        = "AWS"
    }
  }
}

resource "aws_iam_role_policy" "s3_scala_releases_read" {
  policy = data.aws_iam_policy_document.s3_scala_releases_read.json
  role   = aws_iam_role.s3_scala_releases_read.name
}

data "aws_iam_policy_document" "s3_scala_releases_read" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "arn:aws:s3:::releases.mvn-repo.wellcomecollection.org/*",
    ]
  }
}

module "s3_releases_scala_sierra_client" {
  source = "../modules/s3_scala_releases"
  name   = "scala-sierra-client"
}

module "s3_releases_scala_fixtures" {
  source = "../modules/s3_scala_releases"
  name   = "fixtures"
}

module "s3_releases_scala_json" {
  source = "../modules/s3_scala_releases"
  name   = "json"
}

module "s3_releases_scala_monitoring" {
  source = "../modules/s3_scala_releases"
  name   = "monitoring"
}

module "s3_releases_scala_storage" {
  source = "../modules/s3_scala_releases"
  name   = "storage"
}

module "s3_releases_scala_messaging" {
  source = "../modules/s3_scala_releases"
  name   = "messaging"
}

module "s3_releases_scala_typesafe" {
  source = "../modules/s3_scala_releases"
  name   = "typesafe-app"
}

module "s3_releases_scala_catalogue_client" {
  source = "../modules/s3_scala_releases"
  name   = "scala-catalogue-client"
}
