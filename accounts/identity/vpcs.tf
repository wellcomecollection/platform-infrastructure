module "identity_vpc" {
  source = "../modules/vpc"

  vpc_name   = "identity-services"
  cidr_block = "172.72.0.0/16"
}
