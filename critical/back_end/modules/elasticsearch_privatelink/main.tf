resource "aws_security_group" "allow_elastic_cloud_vpce" {
  name   = "allow_elastic_cloud_vpce"
  vpc_id = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  tags = {
    Name = "allow_elastic_cloud_vpce"
  }
}

resource "aws_vpc_endpoint" "elastic_cloud_vpce" {
  vpc_id            = var.vpc_id
  service_name      = var.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.allow_elastic_cloud_vpce.id,
  ]

  subnet_ids = var.subnet_ids

  private_dns_enabled = false
}

resource "ec_deployment_traffic_filter" "allow_vpce" {
  provider = ec

  name   = var.traffic_filter_name
  region = "eu-west-1"
  type   = "vpce"

  rule {
    source = aws_vpc_endpoint.elastic_cloud_vpce.id
  }
}

resource "aws_route53_zone" "elastic_cloud_vpce" {
  name = var.ec_vpce_domain

  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53_record" "cname_ec" {
  zone_id = aws_route53_zone.elastic_cloud_vpce.zone_id
  name    = "*.vpce.eu-west-1.aws.elastic-cloud.com"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_vpc_endpoint.elastic_cloud_vpce.dns_entry[0]["dns_name"]]
}
