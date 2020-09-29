# DEPRECATED Catalogue VPC
# Used by:
# - Catalogue Pipeline
# - IIIF Image server (Loris)
# - Reindexer
# - Sierra Adapter

module "catalogue_vpc_delta" {
  source = "../modules/vpc"

  name       = "catalogue"
  cidr_block = "172.31.0.0/16"

  providers = {
    aws = aws.platform
  }
}

# Used by:
# - Item requesting service
# - Catalogue API

module "catalogue_vpc" {
  source = "../modules/vpc"

  name       = "catalogue"
  cidr_block = "172.18.0.0/16"
}
