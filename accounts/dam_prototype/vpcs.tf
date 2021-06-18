module "dam_prototype_vpc" {
  source = "../modules/vpc"

  vpc_name   = "dam-prototype"
  cidr_block = "172.31.0.0/16"
}
