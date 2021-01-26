variable "service" {}
variable "vpc_id" {}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

locals {
  vpc_name  = lookup(data.aws_vpc.selected.tags, "Name", var.vpc_id)
  vpc_label = split("-", local.vpc_name)[0]
}

data "aws_vpc_endpoint_service" "service" {
  service = var.service
}

resource "aws_vpc_endpoint" "endpoint" {
  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Interface"

  security_group_ids = var.security_group_ids

  subnet_ids = var.subnet_ids

  service_name = data.aws_vpc_endpoint_service.service.service_name

  private_dns_enabled = true

  tags = {
    Name = "${local.vpc_label}-${var.service}-vpc_endpoint"
  }
}
