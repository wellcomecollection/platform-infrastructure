resource "aws_security_group" "security_group" {
  name        = "${var.name}-sg"
  description = "Security Group for for the EC2 Image Builder Build Instances"
  vpc_id      = var.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "sg_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.source_cidr
  security_group_id = aws_security_group.security_group.id
  description       = "HTTPS from VPC"
}

resource "aws_security_group_rule" "sg_rdp_ingress" {
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = var.source_cidr
  security_group_id = aws_security_group.security_group.id
  description       = "RDP from the source variable CIDR"
}

resource "aws_security_group_rule" "sg_internet_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security_group.id
  description       = "Access to the internet"
}