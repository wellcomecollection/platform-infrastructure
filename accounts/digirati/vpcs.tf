# Used by:
# - iiif-builder

module "digirati_vpc" {
  source = "../modules/vpc"

  vpc_name   = "iiif-services"
  cidr_block = "172.56.0.0/16"
}

# Used by:
# - London's Pulse: Medical Officer of Health reports

module "moh_vpc" {
  source = "../modules/vpc"

  vpc_name   = "moh"
  cidr_block = "172.57.0.0/16"
}