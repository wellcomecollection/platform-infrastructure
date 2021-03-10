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

  vpc_id     = local.catalogue_vpcs["catalogue_vpc_delta_id"]
  subnet_ids = local.catalogue_vpcs["catalogue_vpc_delta_private_subnets"]

  service_name        = local.ec_eu_west_1_service_name
  ec_vpce_domain      = local.catalogue_pipeline_ec_vpce_domain
  traffic_filter_name = "ec_allow_vpc_endpoint"
}

module "catalogue_privatelink" {
  source = "./modules/elasticsearch_privatelink"

  providers = {
    aws = aws.catalogue
  }

  vpc_id     = local.catalogue_vpcs["catalogue_vpc_id"]
  subnet_ids = local.catalogue_vpcs["catalogue_vpc_private_subnets"]

  service_name        = local.ec_eu_west_1_service_name
  ec_vpce_domain      = local.catalogue_pipeline_ec_vpce_domain
  traffic_filter_name = "ec_allow_catalogue_vpc_endpoint"
}
