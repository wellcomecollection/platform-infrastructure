# Used by:
# - Catalogue Pipeline
# - IIIF Image server (Loris)
# - Reindexer
# - Sierra Adapter

module "catalogue_vpc_delta" {
  source = "./modules/public-private-igw"

  name = "catalogue-172-31-0-0-16"

  cidr_block_vpc = "172.31.0.0/16"

  public_az_count           = "3"
  cidr_block_public         = "172.31.0.0/17"
  cidrsubnet_newbits_public = "2"

  private_az_count           = "3"
  cidr_block_private         = "172.31.128.0/17"
  cidrsubnet_newbits_private = "2"
}

locals {
  storage_cidr_block_vpc     = "172.30.0.0/16"
  storage_cidr_block_public  = "172.30.0.0/17"
  storage_cidr_block_private = "172.30.128.0/17"

  monitoring_cidr_block_vpc     = "172.28.0.0/16"
  monitoring_cidr_block_public  = "172.28.0.0/17"
  monitoring_cidr_block_private = "172.28.128.0/17"

  datascience_cidr_block_vpc     = "172.17.0.0/16"
  datascience_cidr_block_public  = "172.17.0.0/17"
  datascience_cidr_block_private = "172.17.128.0/17"

  catalogue_cidr_block_vpc     = "172.18.0.0/16"
  catalogue_cidr_block_public  = "172.18.0.0/17"
  catalogue_cidr_block_private = "172.18.128.0/17"

  experience_cidr_block_vpc     = "172.19.0.0/16"
  experience_cidr_block_public  = "172.19.0.0/17"
  experience_cidr_block_private = "172.19.128.0/17"
}

module "storage_vpc" {
  source = "./modules/public-private-igw"

  name = "storage-172-30-0-0-16"

  cidr_block_vpc = local.storage_cidr_block_vpc

  public_az_count           = "3"
  cidr_block_public         = local.storage_cidr_block_public
  cidrsubnet_newbits_public = "2"

  private_az_count           = "3"
  cidr_block_private         = local.storage_cidr_block_private
  cidrsubnet_newbits_private = "2"

  providers = {
    aws = aws.storage
  }
}

# Used by:
# - Grafana service
# - Various monitoring lambdas

module "monitoring_vpc_delta" {
  source = "./modules/public-private-igw"

  name = "monitoring-172-28-0-0-16"

  cidr_block_vpc = local.monitoring_cidr_block_vpc

  public_az_count           = "3"
  cidr_block_public         = local.monitoring_cidr_block_public
  cidrsubnet_newbits_public = "2"

  private_az_count           = "3"
  cidr_block_private         = local.monitoring_cidr_block_private
  cidrsubnet_newbits_private = "2"
}

# Used by:
# - Data science service
# - Labs apps & data scientist infra

module "datascience_vpc" {
  source = "./modules/public-private-igw"

  name = "datascience-172-17-0-0-16"

  cidr_block_vpc = local.datascience_cidr_block_vpc

  public_az_count           = "3"
  cidr_block_public         = local.datascience_cidr_block_public
  cidrsubnet_newbits_public = "2"

  private_az_count           = "3"
  cidr_block_private         = local.datascience_cidr_block_private
  cidrsubnet_newbits_private = "2"

  providers = {
    aws = aws.datascience
  }
}

# Used by:
# - Item requesting service
# - Catalogue API

module "catalogue_vpc" {
  source = "./modules/public-private-igw"

  name = "catalogue-172-18-0-0-16"

  cidr_block_vpc = local.catalogue_cidr_block_vpc

  public_az_count           = "3"
  cidr_block_public         = local.catalogue_cidr_block_public
  cidrsubnet_newbits_public = "2"

  private_az_count           = "3"
  cidr_block_private         = local.catalogue_cidr_block_private
  cidrsubnet_newbits_private = "2"

  providers = {
    aws = aws.catalogue
  }
}

# Used by:
# - wellcomecollection.org

module "experience_vpc" {
  source = "./modules/public-private-igw"

  name = "experience-172-19-0-0-16"

  cidr_block_vpc = local.experience_cidr_block_vpc

  public_az_count           = "3"
  cidr_block_public         = local.experience_cidr_block_public
  cidrsubnet_newbits_public = "2"

  private_az_count           = "3"
  cidr_block_private         = local.experience_cidr_block_private
  cidrsubnet_newbits_private = "2"

  providers = {
    aws = aws.experience
  }
}
