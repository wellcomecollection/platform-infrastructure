variable "friendly_name" {
  description = "Friendly name, used for topic and role policy (e.g. iiif, api)"
  type        = string
}

variable "distribution_id" {
  description = "Id of CloudFront distro"
  type        = string
}

variable "runtime" {
  description = "Temporary: allows setting a specific node runtime at the module level"
  type        = string
}

locals {
  lambda_bucket = "wellcomecollection-platform-infra"
  lambda_key    = "lambdas/cloudfront_invalidation/sns_handler.zip"
}