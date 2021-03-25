output "wellcome_library_redirect_arn_latest" {
  value = local.wellcome_library_redirect_arn_latest
}

output "wellcome_library_blog_redirect_arn_latest" {
  value = local.wellcome_library_blog_redirect_arn_latest
}

output "wellcome_library_passthru_arn_latest" {
  value = local.wellcome_library_passthru_arn_latest
}

output "wellcome_library_redirect_lambda_s3_object_version" {
  value = data.aws_s3_bucket_object.wellcome_library_redirect.version_id
}