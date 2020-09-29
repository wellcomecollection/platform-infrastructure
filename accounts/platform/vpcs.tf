module "ci_vpc" {
  source = "../modules/vpc"

  name       = "ci"
  cidr_block = "172.43.0.0/16"
}

module "developer_vpc" {
  source = "../modules/vpc"

  name       = "developer"
  cidr_block = "172.42.0.0/16"
}

# Used by:
# - Grafana service
# - Various monitoring lambdas

module "monitoring_vpc_delta" {
  source = "../modules/vpc"

  name       = "monitoring"
  cidr_block = "172.28.0.0/16"
}
