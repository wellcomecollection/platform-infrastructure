variable "name" {
  type    = string
  default = ""
}

variable "vpc_name" {
  type    = string
  default = ""
}

variable "cidr_block" {
  type = string
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "public_route_table_id" {
  value = module.vpc.public_route_table_id
}

output "private_route_table_id" {
  value = module.vpc.private_route_table_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

locals {
  vpc_name = var.name == "" ? var.vpc_name : replace("${var.name}-${var.cidr_block}", "/", "-")

  cidr_block_public  = cidrsubnet(var.cidr_block, 1, 0)
  cidr_block_private = cidrsubnet(var.cidr_block, 1, 1)
}

output "cidr_block_public" {
  value = local.cidr_block_public
}

output "cidr_block_private" {
  value = local.cidr_block_private
}

module "vpc" {
  source = "../../../critical/back_end/modules/public-private-igw"

  name = local.vpc_name

  cidr_block_vpc = var.cidr_block

  public_az_count           = 3
  cidr_block_public         = local.cidr_block_public
  cidrsubnet_newbits_public = 2

  private_az_count           = 3
  cidr_block_private         = local.cidr_block_private
  cidrsubnet_newbits_private = 2
}
