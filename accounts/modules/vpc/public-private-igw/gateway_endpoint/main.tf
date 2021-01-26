data "aws_vpc_endpoint_service" "service" {
  service = var.service
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

locals {
  vpc_name  = lookup(data.aws_vpc.selected.tags, "Name", var.vpc_id)
  vpc_label = split("-", local.vpc_name)[0]
}

resource "aws_vpc_endpoint" "endpoint" {
  vpc_id       = var.vpc_id
  service_name = data.aws_vpc_endpoint_service.service.service_name

  route_table_ids = [var.route_table_id]

  tags = {
    Name = "${local.vpc_label}-${var.service}-vpc_endpoint"
  }
}
