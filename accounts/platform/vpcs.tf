# Used by:
# - Grafana service
# - Various monitoring lambdas

module "monitoring_vpc_delta" {
  source = "../modules/vpc"

  name       = "monitoring"
  cidr_block = "172.28.0.0/16"
}
