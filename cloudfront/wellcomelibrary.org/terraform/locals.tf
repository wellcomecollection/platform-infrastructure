locals {
  wellcome_library_redirect_arn           = aws_lambda_function.wellcome_library_redirect.arn
  wellcome_library_redirect_stage_version = aws_lambda_function.wellcome_library_redirect.version
  wellcome_library_redirect_arn_stage     = "${local.wellcome_library_redirect_arn}:${local.wellcome_library_redirect_stage_version}"
  wellcome_library_redirect_arn_prod      = "${local.wellcome_library_redirect_arn}:${local.prod_lambda_function_versions["wellcomelibrary"]}"

  wellcome_library_passthru_arn           = aws_lambda_function.wellcome_library_passthru.arn
  wellcome_library_passthru_stage_version = aws_lambda_function.wellcome_library_passthru.version
  wellcome_library_passthru_arn_stage     = "${local.wellcome_library_passthru_arn}:${local.wellcome_library_passthru_stage_version}"
  wellcome_library_passthru_arn_prod      = "${local.wellcome_library_passthru_arn}:${local.prod_lambda_function_versions["passthru"]}"

  wellcome_library_blog_arn                = aws_lambda_function.wellcome_library_blog_redirect.arn
  wellcome_library_blog_stage_version      = aws_lambda_function.wellcome_library_blog_redirect.version
  wellcome_library_blog_redirect_arn_stage = "${local.wellcome_library_blog_arn}:${local.wellcome_library_blog_stage_version}"
  wellcome_library_blog_redirect_arn_prod  = "${local.wellcome_library_blog_arn}:${local.prod_lambda_function_versions["blog"]}"

  wellcome_library_archive_arn                = aws_lambda_function.wellcome_library_archive_redirect.arn
  wellcome_library_archive_stage_version      = aws_lambda_function.wellcome_library_archive_redirect.version
  wellcome_library_archive_redirect_arn_stage = "${local.wellcome_library_archive_arn}:${local.wellcome_library_archive_stage_version}"
  wellcome_library_archive_redirect_arn_prod  = "${local.wellcome_library_archive_arn}:${local.prod_lambda_function_versions["archive"]}"

  wellcome_library_encore_arn                = aws_lambda_function.wellcome_library_encore_redirect.arn
  wellcome_library_encore_stage_version      = aws_lambda_function.wellcome_library_encore_redirect.version
  wellcome_library_encore_redirect_arn_stage = "${local.wellcome_library_encore_arn}:${local.wellcome_library_encore_stage_version}"
  wellcome_library_encore_redirect_arn_prod  = "${local.wellcome_library_encore_arn}:${local.prod_lambda_function_versions["encore"]}"

  edge_lambdas_bucket = data.terraform_remote_state.cloudfront_core.outputs.edge_lambdas_bucket
}