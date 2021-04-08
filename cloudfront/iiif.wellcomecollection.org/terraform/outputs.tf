# This output is used to inform the developer making changes which is the latest version
# The latest version will be used in the stage env by default, but should be set
# manually in prod, after verifying correct behaviour.

output "dlcs_path_rewrite_arn_latest" {
  value = local.dlcs_path_rewrite_arn_latest
}

# Cloudfront distribution id for all environments
output "iiif_prod_distribution_id" {
  value = module.iiif-prod.distribution_id
}

output "iiif_stage_distribution_id" {
  value = module.iiif-stage.distribution_id
}

output "iiif_test_distribution_id" {
  value = module.iiif-test.distribution_id
}