# This enables public access to the ES cluster (with the usual x-pack auth proviso)
# TODO: Restrict this to Wellcome internal IP addresses when physical office access is restored
resource "ec_deployment_traffic_filter" "public_internet" {
  provider = ec

  name   = "public_access"
  region = "eu-west-1"
  type   = "ip"

  rule {
    source = "0.0.0.0/0"
  }
}

locals {
  catalogue_pipeline_ec_vpce_domain = "vpce.eu-west-1.aws.elastic-cloud.com"

  # The correct endpoints are provided by Elastic Cloud
  # https://www.elastic.co/guide/en/cloud/current/ec-traffic-filtering-vpc.html
  ec_eu_west_1_service_name = "com.amazonaws.vpce.eu-west-1.vpce-svc-01f2afe87944eb12b"
}

module "platform_privatelink" {
  source = "./modules/elasticsearch_privatelink"

  providers = {
    aws = aws.platform
  }

  traffic_filter_name = "ec_allow_vpc_endpoint"

  vpc_id     = local.catalogue_vpcs["catalogue_vpc_delta_id"]
  subnet_ids = local.catalogue_vpcs["catalogue_vpc_delta_private_subnets"]

  service_name   = local.ec_eu_west_1_service_name
  ec_vpce_domain = local.catalogue_pipeline_ec_vpce_domain
}

module "catalogue_privatelink" {
  source = "./modules/elasticsearch_privatelink"

  providers = {
    aws = aws.catalogue
  }

  traffic_filter_name = "ec_allow_catalogue_vpc_endpoint"

  vpc_id     = local.catalogue_vpcs["catalogue_vpc_id"]
  subnet_ids = local.catalogue_vpcs["catalogue_vpc_private_subnets"]

  service_name   = local.ec_eu_west_1_service_name
  ec_vpce_domain = local.catalogue_pipeline_ec_vpce_domain
}

module "storage_privatelink" {
  source = "./modules/elasticsearch_privatelink"

  providers = {
    aws = aws.storage
  }

  traffic_filter_name = "storage"

  vpc_id     = local.storage_vpcs["storage_vpc_id"]
  subnet_ids = local.storage_vpcs["storage_vpc_private_subnets"]

  service_name   = local.ec_eu_west_1_service_name
  ec_vpce_domain = local.catalogue_pipeline_ec_vpce_domain
}

module "experience_privatelink" {
  source = "./modules/elasticsearch_privatelink"

  providers = {
    aws = aws.experience
  }

  traffic_filter_name = "experience"

  vpc_id     = local.experience_vpcs["experience_vpc_id"]
  subnet_ids = local.experience_vpcs["experience_vpc_private_subnets"]

  service_name   = local.ec_eu_west_1_service_name
  ec_vpce_domain = local.catalogue_pipeline_ec_vpce_domain
}

module "digirati_privatelink" {
  source = "./modules/elasticsearch_privatelink"

  providers = {
    aws = aws.digirati
  }

  traffic_filter_name = "digirati"

  vpc_id     = local.digirati_vpcs["digirati_vpc_id"]
  subnet_ids = local.digirati_vpcs["digirati_vpc_private_subnets"]

  service_name   = local.ec_eu_west_1_service_name
  ec_vpce_domain = local.catalogue_pipeline_ec_vpce_domain
}

module "identity_prod_privatelink" {
  source = "./modules/elasticsearch_privatelink"

  providers = {
    aws = aws.identity
  }

  traffic_filter_name = "identity_prod"

  vpc_id     = local.identity_vpcs["identity_prod_vpc_id"]
  subnet_ids = local.identity_vpcs["identity_prod_vpc_private_subnets"]

  service_name   = local.ec_eu_west_1_service_name
  ec_vpce_domain = local.catalogue_pipeline_ec_vpce_domain
}

module "identity_stage_privatelink" {
  source = "./modules/elasticsearch_privatelink"

  providers = {
    aws = aws.identity
  }

  traffic_filter_name = "identity_stage"

  vpc_id     = local.identity_vpcs["identity_stage_vpc_id"]
  subnet_ids = local.identity_vpcs["identity_stage_vpc_private_subnets"]

  service_name   = local.ec_eu_west_1_service_name
  ec_vpce_domain = local.catalogue_pipeline_ec_vpce_domain
}

module "workflow_prod_privatelink" {
  source = "./modules/elasticsearch_privatelink"

  providers = {
    aws = aws.workflow
  }

  traffic_filter_name = "workflow_prod"

  vpc_id     = local.workflow_prod_vpcs["vpc_id"]
  subnet_ids = local.workflow_prod_vpcs["private_subnets"]

  service_name   = local.ec_eu_west_1_service_name
  ec_vpce_domain = local.catalogue_pipeline_ec_vpce_domain
}

module "workflow_stage_privatelink" {
  source = "./modules/elasticsearch_privatelink"

  providers = {
    aws = aws.workflow
  }

  traffic_filter_name = "workflow_stage"

  vpc_id     = local.workflow_stage_vpcs["vpc_id"]
  subnet_ids = local.workflow_stage_vpcs["private_subnets"]

  service_name   = local.ec_eu_west_1_service_name
  ec_vpce_domain = local.catalogue_pipeline_ec_vpce_domain
}
