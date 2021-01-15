resource "aws_lambda_function" "dlcs_path_rewrite" {
  provider = aws.us_east_1

  function_name = "cf_edge_dlcs_path_rewrite"
  role          = aws_iam_role.edge_lambda_role.arn
  runtime       = "nodejs12.x"
  handler       = "dlcs_path_rewite.request"
  filename      = "${path.module}/edge-lambda/dlcs_path_rewrite.zip"
  publish       = true
}

data "archive_file" "dlcs_path_rewite" {
  type        = "zip"
  source_file = "${path.module}/edge-lambda/dlcs_path_rewrite.js"
  output_path = "${path.module}/edge-lambda/dlcs_path_rewrite.zip"
}

resource "aws_iam_role" "edge_lambda_role" {
  provider = aws.us_east_1

  name_prefix        = "edge_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
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