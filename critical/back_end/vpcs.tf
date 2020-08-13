locals {
  storage_cidr_block_vpc     = "172.30.0.0/16"
  storage_cidr_block_public  = cidrsubnet(local.storage_cidr_block_vpc, 1, 0)
  storage_cidr_block_private = cidrsubnet(local.storage_cidr_block_vpc, 1, 1)

  monitoring_cidr_block_vpc     = "172.28.0.0/16"
  monitoring_cidr_block_public  = cidrsubnet(local.monitoring_cidr_block_vpc, 1, 0)
  monitoring_cidr_block_private = cidrsubnet(local.monitoring_cidr_block_vpc, 1, 1)

  datascience_cidr_block_vpc     = "172.17.0.0/16"
  datascience_cidr_block_public  = cidrsubnet(local.datascience_cidr_block_vpc, 1, 0)
  datascience_cidr_block_private = cidrsubnet(local.datascience_cidr_block_vpc, 1, 1)

  catalogue_delta_cidr_block_vpc     = "172.31.0.0/16"
  catalogue_delta_cidr_block_public  = cidrsubnet(local.catalogue_delta_cidr_block_vpc, 1, 0)
  catalogue_delta_cidr_block_private = cidrsubnet(local.catalogue_delta_cidr_block_vpc, 1, 1)

  catalogue_cidr_block_vpc     = "172.18.0.0/16"
  catalogue_cidr_block_public  = cidrsubnet(local.catalogue_cidr_block_vpc, 1, 0)
  catalogue_cidr_block_private = cidrsubnet(local.catalogue_cidr_block_vpc, 1, 1)

  experience_cidr_block_vpc     = "172.19.0.0/16"
  experience_cidr_block_public  = cidrsubnet(local.experience_cidr_block_vpc, 1, 0)
  experience_cidr_block_private = cidrsubnet(local.experience_cidr_block_vpc, 1, 1)

  developer_cidr_block_vpc     = "172.42.0.0/16"
  developer_cidr_block_public  = cidrsubnet(local.developer_cidr_block_vpc, 1, 0)
  developer_cidr_block_private = cidrsubnet(local.developer_cidr_block_vpc, 1, 1)

  digirati_cidr_block_vpc     = "172.56.0.0/16"
  digirati_cidr_block_public  = cidrsubnet(local.digirati_cidr_block_vpc, 1, 0)
  digirati_cidr_block_private = cidrsubnet(local.digirati_cidr_block_vpc, 1, 1)
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

  providers = {
    aws = aws.platform
  }
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

# DEPRECATED Catalogue VPC
# Used by:
# - Catalogue Pipeline
# - IIIF Image server (Loris)
# - Reindexer
# - Sierra Adapter

module "catalogue_vpc_delta" {
  source = "./modules/public-private-igw"

  name = "catalogue-172-31-0-0-16"

  cidr_block_vpc = local.catalogue_delta_cidr_block_vpc

  public_az_count           = "3"
  cidr_block_public         = local.catalogue_delta_cidr_block_public
  cidrsubnet_newbits_public = "2"

  private_az_count           = "3"
  cidr_block_private         = local.catalogue_delta_cidr_block_private
  cidrsubnet_newbits_private = "2"

  providers = {
    aws = aws.platform
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

# Used by:
# - iiif-builder

module "digirati_vpc" {
  source = "./modules/public-private-igw"

  name = "iiif-services"

  cidr_block_vpc = local.digirati_cidr_block_vpc

  public_az_count           = "3"
  cidr_block_public         = local.digirati_cidr_block_public
  cidrsubnet_newbits_public = "2"

  private_az_count           = "3"
  cidr_block_private         = local.digirati_cidr_block_private
  cidrsubnet_newbits_private = "2"

  providers = {
    aws = aws.digirati
  }
}
