locals {
  wellcome_library_redirect_arn        = aws_lambda_function.wellcome_library_redirect.arn
  wellcome_library_redirect_latest     = aws_lambda_function.wellcome_library_redirect.version
  wellcome_library_redirect_arn_latest = "${local.wellcome_library_redirect_arn}:${local.wellcome_library_redirect_latest}"
  wellcome_library_redirect_arn_stage  = local.wellcome_library_redirect_arn_latest
  # This should be set manually when a stable prod deploy is established.
  wellcome_library_redirect_arn_prod = "${local.wellcome_library_redirect_arn}:76"

  wellcome_library_passthru_arn        = aws_lambda_function.wellcome_library_passthru.arn
  wellcome_library_passthru_latest     = aws_lambda_function.wellcome_library_passthru.version
  wellcome_library_passthru_arn_latest = "${local.wellcome_library_passthru_arn}:${local.wellcome_library_passthru_latest}"
  wellcome_library_passthru_arn_stage  = local.wellcome_library_passthru_arn_latest
  # This should be set manually when a stable prod deploy is established.
  wellcome_library_passthru_arn_prod = "${local.wellcome_library_passthru_arn}:37"

  wellcome_library_blog_redirect_arn        = aws_lambda_function.wellcome_library_blog_redirect.arn
  wellcome_library_blog_redirect_latest     = aws_lambda_function.wellcome_library_blog_redirect.version
  wellcome_library_blog_redirect_arn_latest = "${local.wellcome_library_blog_redirect_arn}:${local.wellcome_library_blog_redirect_latest}"
  wellcome_library_blog_redirect_arn_stage  = "${local.wellcome_library_blog_redirect_arn}:12"
  # This should be set manually when a stable prod deploy is established.
  wellcome_library_blog_redirect_arn_prod = "${local.wellcome_library_blog_redirect_arn}:12"

  wellcome_library_archive_redirect_arn        = aws_lambda_function.wellcome_library_archive_redirect.arn
  wellcome_library_archive_redirect_latest     = aws_lambda_function.wellcome_library_archive_redirect.version
  wellcome_library_archive_redirect_arn_latest = "${local.wellcome_library_archive_redirect_arn}:${local.wellcome_library_archive_redirect_latest}"
  wellcome_library_archive_redirect_arn_stage  = local.wellcome_library_archive_redirect_arn_latest
  # This should be set manually when a stable prod deploy is established.
  wellcome_library_archive_redirect_arn_prod = "${local.wellcome_library_archive_redirect_arn}:22"

  wellcome_library_encore_redirect_arn        = aws_lambda_function.wellcome_library_encore_redirect.arn
  wellcome_library_encore_redirect_latest     = aws_lambda_function.wellcome_library_encore_redirect.version
  wellcome_library_encore_redirect_arn_latest = "${local.wellcome_library_encore_redirect_arn}:${local.wellcome_library_encore_redirect_latest}"
  wellcome_library_encore_redirect_arn_stage  = local.wellcome_library_encore_redirect_arn_latest
  # This should be set manually when a stable prod deploy is established.
  wellcome_library_encore_redirect_arn_prod = local.wellcome_library_encore_redirect_arn_latest

  edge_lambdas_bucket = data.terraform_remote_state.cloudfront_core.outputs.edge_lambdas_bucket
}