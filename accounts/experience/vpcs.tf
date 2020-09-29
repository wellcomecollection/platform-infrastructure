# Used by:
# - wellcomecollection.org

module "experience_vpc" {
  source = "../modules/vpc"

  name       = "experience"
  cidr_block = "172.19.0.0/16"
}
