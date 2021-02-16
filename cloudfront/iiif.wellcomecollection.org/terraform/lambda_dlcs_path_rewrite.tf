resource "aws_lambda_function" "dlcs_path_rewrite" {
  provider = aws.us_east_1

  function_name = "cf_edge_dlcs_path_rewrite"
  role          = aws_iam_role.edge_lambda_role.arn
  runtime       = "nodejs12.x"
  handler       = "dlcs_path_rewrite.request"
  publish       = true

  s3_bucket         = data.aws_s3_bucket_object.dlcs_path_rewrite.bucket
  s3_key            = data.aws_s3_bucket_object.dlcs_path_rewrite.key
  s3_object_version = data.aws_s3_bucket_object.dlcs_path_rewrite.version_id
}

data "aws_s3_bucket_object" "dlcs_path_rewrite" {
  provider = aws.us_east_1

  bucket = local.edge_lambdas_bucket
  key    = "iiif/dlcs_path_rewrite.zip"
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
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
      ]
    }
  }
}