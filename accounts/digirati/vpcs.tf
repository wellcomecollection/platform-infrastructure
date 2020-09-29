# Used by:
# - iiif-builder

module "digirati_vpc" {
  source = "../modules/vpc"

  vpc_name   = "iiif-services"
  cidr_block = "172.56.0.0/16"
}
