locals {
  dlcs_path_rewrite_arn        = aws_lambda_function.dlcs_path_rewrite.arn
  dlcs_path_rewrite_latest     = aws_lambda_function.dlcs_path_rewrite.version
  dlcs_path_rewrite_arn_latest = "${local.dlcs_path_rewrite_arn}:${local.dlcs_path_rewrite_latest}"
  dlcs_path_rewrite_arn_stage  = local.dlcs_path_rewrite_arn_latest
  dlcs_path_rewrite_arn_prod   = "${local.dlcs_path_rewrite_arn}:34"

  edge_lambdas_bucket = data.terraform_remote_state.cloudfront_core.outputs.edge_lambdas_bucket
}