module "storage_vpc" {
  source = "../modules/vpc"

  name       = "storage"
  cidr_block = "172.30.0.0/16"
}
