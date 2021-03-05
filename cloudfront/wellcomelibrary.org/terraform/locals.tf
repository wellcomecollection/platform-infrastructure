locals {
  wellcome_library_redirect_arn        = aws_lambda_function.wellcome_library_redirect.arn
  wellcome_library_redirect_latest     = aws_lambda_function.wellcome_library_redirect.version
  wellcome_library_redirect_arn_latest = "${local.wellcome_library_redirect_arn}:${local.wellcome_library_redirect_latest}"
  wellcome_library_redirect_arn_stage  = local.wellcome_library_redirect_arn_latest
  # This should be set manually when a stable prod deploy is established.
  wellcome_library_redirect_arn_prod = "${local.wellcome_library_redirect_arn}:10"

  edge_lambdas_bucket = data.terraform_remote_state.cloudfront_core.outputs.edge_lambdas_bucket
}