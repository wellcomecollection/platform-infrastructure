resource "aws_lambda_function" "wellcome_library_passthru" {
  provider = aws.us_east_1

  function_name = "cf_edge_wellcome_library_passthru"
  role          = aws_iam_role.edge_lambda_role.arn
  runtime       = "nodejs12.x"
  handler       = "wellcomeLibraryPassthru.requestHandler"
  publish       = true

  s3_bucket         = data.aws_s3_bucket_object.wellcome_library_redirect.bucket
  s3_key            = data.aws_s3_bucket_object.wellcome_library_redirect.key
  s3_object_version = data.aws_s3_bucket_object.wellcome_library_redirect.version_id
}

resource "aws_lambda_function" "wellcome_library_encore_redirect" {
  provider = aws.us_east_1

  function_name = "cf_edge_wellcome_library_encore_redirect"
  role          = aws_iam_role.edge_lambda_role.arn
  runtime       = "nodejs12.x"
  handler       = "wellcomeLibraryencoreRedirect.requestHandler"
  publish       = true

  s3_bucket         = data.aws_s3_bucket_object.wellcome_library_redirect.bucket
  s3_key            = data.aws_s3_bucket_object.wellcome_library_redirect.key
  s3_object_version = data.aws_s3_bucket_object.wellcome_library_redirect.version_id
}

resource "aws_lambda_function" "wellcome_library_archive_redirect" {
  provider = aws.us_east_1

  function_name = "cf_edge_wellcome_library_archive_redirect"
  role          = aws_iam_role.edge_lambda_role.arn
  runtime       = "nodejs12.x"
  handler       = "wellcomeLibraryArchiveRedirect.requestHandler"
  publish       = true

  s3_bucket         = data.aws_s3_bucket_object.wellcome_library_redirect.bucket
  s3_key            = data.aws_s3_bucket_object.wellcome_library_redirect.key
  s3_object_version = data.aws_s3_bucket_object.wellcome_library_redirect.version_id
}

resource "aws_lambda_function" "wellcome_library_blog_redirect" {
  provider = aws.us_east_1

  function_name = "cf_edge_wellcome_library_blog_redirect"
  role          = aws_iam_role.edge_lambda_role.arn
  runtime       = "nodejs12.x"
  handler       = "wellcomeLibraryBlogRedirect.requestHandler"
  publish       = true

  s3_bucket         = data.aws_s3_bucket_object.wellcome_library_redirect.bucket
  s3_key            = data.aws_s3_bucket_object.wellcome_library_redirect.key
  s3_object_version = data.aws_s3_bucket_object.wellcome_library_redirect.version_id
}

resource "aws_lambda_function" "wellcome_library_redirect" {
  provider = aws.us_east_1

  function_name = "cf_edge_wellcome_library_redirect"
  role          = aws_iam_role.edge_lambda_role.arn
  runtime       = "nodejs12.x"
  handler       = "wellcomeLibraryRedirect.requestHandler"
  publish       = true

  s3_bucket         = data.aws_s3_bucket_object.wellcome_library_redirect.bucket
  s3_key            = data.aws_s3_bucket_object.wellcome_library_redirect.key
  s3_object_version = data.aws_s3_bucket_object.wellcome_library_redirect.version_id
}

data "aws_s3_bucket_object" "wellcome_library_redirect" {
  provider = aws.us_east_1

  bucket = local.edge_lambdas_bucket
  key    = "wellcome_library/wellcome_library_redirect.zip"
}

resource "aws_iam_role" "edge_lambda_role" {
  provider = aws.us_east_1

  name_prefix        = "edge_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "basic_execution_role" {
  role       = aws_iam_role.edge_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "edgelambda.amazonaws.com",
        "lambda.amazonaws.com",
      ]
    }
  }
}