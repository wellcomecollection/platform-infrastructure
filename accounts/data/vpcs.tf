# Used by:
# - Data science service
# - Labs apps & data scientist infra

module "datascience_vpc" {
  source = "../modules/vpc"

  name       = "datascience"
  cidr_block = "172.17.0.0/16"
}
