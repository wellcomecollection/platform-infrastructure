output "lambda_error_alarm_arn" {
  value = module.lambda_error_alarm.arn
}

output "gateway_server_error_alarm_arn" {
  value = module.gateway_server_error_alarm.arn
}

output "bucket_alb_logs_id" {
  value = aws_s3_bucket.alb_logs.id
}

output "terraform_apply_topic_name" {
  value = module.terraform_apply_topic.name
}

output "cloudfront_logs_bucket_domain_name" {
  value = aws_s3_bucket.cloudfront_logs.bucket_domain_name
}

output "infra_bucket_arn" {
  value = aws_s3_bucket.platform_infra.arn
}

output "infra_bucket" {
  value = aws_s3_bucket.platform_infra.id
}

# Source data update topics

## miro
output "miro_updates_topic_arn" {
  value = module.miro_updates_topic.arn
}

output "miro_updates_topic_name" {
  value = module.miro_updates_topic.name
}

# Reindexing topics

## Reporting - miro

output "reporting_miro_reindex_topic_arn" {
  value = module.reporting_miro_reindex_topic.arn
}

output "reporting_miro_reindex_topic_name" {
  value = module.reporting_miro_reindex_topic.name
}

## Reporting - miro inventory

output "reporting_miro_inventory_reindex_topic_arn" {
  value = module.reporting_miro_inventory_reindex_topic.arn
}

output "reporting_miro_inventory_reindex_topic_name" {
  value = module.reporting_miro_inventory_reindex_topic.name
}

## Reporting - sierra

output "reporting_sierra_reindex_topic_arn" {
  value = module.reporting_sierra_reindex_topic.arn
}

output "reporting_sierra_reindex_topic_name" {
  value = module.reporting_sierra_reindex_topic.name
}

## Catalogue - miro

output "catalogue_miro_reindex_topic_arn" {
  value = module.catalogue_miro_reindex_topic.arn
}

output "catalogue_miro_reindex_topic_name" {
  value = module.catalogue_miro_reindex_topic.name
}

## Catalogue - sierra

output "catalogue_sierra_reindex_topic_arn" {
  value = module.catalogue_sierra_reindex_topic.arn
}

output "catalogue_sierra_reindex_topic_name" {
  value = module.catalogue_sierra_reindex_topic.name
}

## Catalogue - sierra items

output "catalogue_sierra_items_reindex_topic_arn" {
  value = module.catalogue_sierra_items_reindex_topic.arn
}

output "catalogue_sierra_items_reindex_topic_name" {
  value = module.catalogue_sierra_items_reindex_topic.name
}

## Inference - calm

output "inference_calm_reindex_topic_arn" {
  value = module.inference_calm_reindex_topic.arn
}

output "inference_calm_reindex_topic_name" {
  value = module.inference_calm_reindex_topic.name
}

# Shared secrets

output "shared_secrets_logging" {
  value = local.logging_secrets
}

output "shared_secrets_apm" {
  value = local.apm_secrets
}

# Elastic Cloud

output "ec_public_internet_traffic_filter_id" {
  value = ec_deployment_traffic_filter.public_internet.id
}

output "ec_platform_privatelink_sg_id" {
  value = module.platform_privatelink.security_group_id
}

output "ec_catalogue_privatelink_sg_id" {
  value = module.catalogue_privatelink.security_group_id
}

output "ec_storage_privatelink_sg_id" {
  value = module.storage_privatelink.security_group_id
}

output "ec_experience_privatelink_sg_id" {
  value = module.experience_privatelink.security_group_id
}

output "ec_digirati_privatelink_sg_id" {
  value = module.digirati_privatelink.security_group_id
}

output "ec_identity_prod_privatelink_sg_id" {
  value = module.identity_prod_privatelink.security_group_id
}

output "ec_identity_stage_privatelink_sg_id" {
  value = module.identity_stage_privatelink.security_group_id
}

output "ec_workflow_stage_privatelink_sg_id" {
  value = module.workflow_stage_privatelink.security_group_id
}

output "ec_workflow_prod_privatelink_sg_id" {
  value = module.workflow_prod_privatelink.security_group_id
}

output "ec_platform_privatelink_traffic_filter_id" {
  value = module.platform_privatelink.traffic_filter_vpce_id
}

output "ec_catalogue_privatelink_traffic_filter_id" {
  value = module.catalogue_privatelink.traffic_filter_vpce_id
}

output "ec_storage_privatelink_traffic_filter_id" {
  value = module.storage_privatelink.traffic_filter_vpce_id
}

output "ec_experience_privatelink_traffic_filter_id" {
  value = module.experience_privatelink.traffic_filter_vpce_id
}

output "ec_digirati_privatelink_traffic_filter_id" {
  value = module.digirati_privatelink.traffic_filter_vpce_id
}

output "ec_identity_prod_privatelink_traffic_filter_id" {
  value = module.identity_prod_privatelink.traffic_filter_vpce_id
}

output "ec_identity_stage_privatelink_traffic_filter_id" {
  value = module.identity_stage_privatelink.traffic_filter_vpce_id
}

output "ec_workflow_stage_privatelink_traffic_filter_id" {
  value = module.workflow_stage_privatelink.traffic_filter_vpce_id
}

output "ec_workflow_prod_privatelink_traffic_filter_id" {
  value = module.workflow_prod_privatelink.traffic_filter_vpce_id
}

output "logging_kibana_endpoint" {
  value = local.logging_kibana_endpoint
}

# Logging cluster identifier

output "logging_cluster_id" {
  value = ec_deployment.logging.id
}
