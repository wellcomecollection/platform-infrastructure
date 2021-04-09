# topic and handler for invalidating iiif.wc.org paths
module "iiif_prod" {
  source = "./sns_lambda"

  friendly_name   = "iiif-prod"
  distribution_id = data.terraform_remote_state.iiif_wc_cloudfront.outputs.iiif_prod_distribution_id
}

# topic and handler for invalidating iiif-stage.wc.org paths
module "iiif_stage" {
  source = "./sns_lambda"

  friendly_name   = "iiif-stage"
  distribution_id = data.terraform_remote_state.iiif_wc_cloudfront.outputs.iiif_stage_distribution_id
}

# topic and handler for invalidating iiif-test.wc.org paths
module "iiif_test" {
  source = "./sns_lambda"

  friendly_name   = "iiif-test"
  distribution_id = data.terraform_remote_state.iiif_wc_cloudfront.outputs.iiif_test_distribution_id
}

# topic and handler for invalidating api.wc.org paths
module "api_prod" {
  source = "./sns_lambda"

  friendly_name   = "api-prod"
  distribution_id = data.terraform_remote_state.api_wc_cloudfront.outputs.wellcomecollection_prod_distribution_id
}

# topic and handler for invalidating api-stage.wc.org paths
module "api_stage" {
  source = "./sns_lambda"

  friendly_name   = "api-stage"
  distribution_id = data.terraform_remote_state.api_wc_cloudfront.outputs.wellcomecollection_stage_distribution_id
}