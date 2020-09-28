locals {
  developer_cidr_block_vpc     = "172.42.0.0/16"
  developer_cidr_block_public  = cidrsubnet(local.developer_cidr_block_vpc, 1, 0)
  developer_cidr_block_private = cidrsubnet(local.developer_cidr_block_vpc, 1, 1)
}

module "developer_vpc" {
  source = "./modules/public-private-igw"

  name = "developer-172-42-0-0-16"

  cidr_block_vpc = local.developer_cidr_block_vpc

  public_az_count           = "3"
  cidr_block_public         = local.developer_cidr_block_public
  cidrsubnet_newbits_public = "2"

  private_az_count           = "3"
  cidr_block_private         = local.developer_cidr_block_private
  cidrsubnet_newbits_private = "2"

  providers = {
    aws = aws.platform
  }
}
