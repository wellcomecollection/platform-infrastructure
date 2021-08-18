# Shared topics for reindexing

## Reporting

module "reporting_miro_reindex_topic" {
  source                         = "github.com/wellcomecollection/terraform-aws-sns-topic.git?ref=v1.0.0"
  name                           = "reporting_miro_reindex_topic"
  cross_account_subscription_ids = [local.account_ids["reporting"]]
}

module "reporting_sierra_reindex_topic" {
  source = "github.com/wellcomecollection/terraform-aws-sns-topic.git?ref=v1.0.0"
  name   = "reporting_sierra_reindex_topic"

  cross_account_subscription_ids = [
    local.account_ids["reporting"],
  ]
}

module "reporting_miro_inventory_reindex_topic" {
  source                         = "github.com/wellcomecollection/terraform-aws-sns-topic.git?ref=v1.0.0"
  name                           = "reporting_miro_inventory_reindex_topic"
  cross_account_subscription_ids = [local.account_ids["reporting"]]
}

## Catalogue

module "catalogue_miro_reindex_topic" {
  source = "github.com/wellcomecollection/terraform-aws-sns-topic.git?ref=v1.0.0"
  name   = "catalogue_miro_reindex_topic"
}

module "catalogue_sierra_reindex_topic" {
  source = "github.com/wellcomecollection/terraform-aws-sns-topic.git?ref=v1.0.0"
  name   = "catalogue_sierra_reindex_topic"
}

module "catalogue_sierra_items_reindex_topic" {
  source = "github.com/wellcomecollection/terraform-aws-sns-topic.git?ref=v1.0.0"
  name   = "catalogue_sierra_items_reindex_topic"
}

## Inference

module "inference_calm_reindex_topic" {
  source = "github.com/wellcomecollection/terraform-aws-sns-topic.git?ref=v1.0.0"
  name   = "inference_calm_reindex_topic"
}

# Shared topics for updates to VHS source data
module "miro_updates_topic" {
  source                         = "github.com/wellcomecollection/terraform-aws-sns-topic.git?ref=v1.0.0"
  name                           = "vhs_sourcedata_miro_updates_topic"
  cross_account_subscription_ids = [local.account_ids["reporting"]]
}
