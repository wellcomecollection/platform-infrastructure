resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block_vpc

  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = var.name
  }
}

module "public_subnets" {
  source = "../public-igw"
  name   = "${var.name}-public"

  vpc_id = aws_vpc.vpc.id

  cidr_block         = var.cidr_block_public
  cidrsubnet_newbits = var.cidrsubnet_newbits_public

  az_count = var.public_az_count
}

module "private_subnets" {
  source = "../subnets"
  name   = "${var.name}-private"

  vpc_id = aws_vpc.vpc.id

  cidr_block         = var.cidr_block_private
  cidrsubnet_newbits = var.cidrsubnet_newbits_private

  az_count = var.private_az_count
}

module "nat" {
  source = "../nat"
  name   = var.name

  subnet_id      = module.public_subnets.subnets[0]
  route_table_id = module.private_subnets.route_table_id
}

resource "aws_network_interface" "nat_instance" {
  security_groups   = [aws_security_group.nat_instance_egress.id]
  subnet_id         = module.public_subnets.subnets[0]
  source_dest_check = false
  description       = "ENI for NAT instance ${var.name}"

  tags = {
    Name = "nat-${var.name}"
  }
}

/*resource "aws_eip" "nat_instance" {
  network_interface = aws_network_interface.nat_instance.id
  vpc               = true

  tags = {
    Name = "nat-${var.name}"
  }
}*/

resource "aws_security_group" "nat_instance_egress" {
  vpc_id      = aws_vpc.vpc.id
  description = "Security group for NAT instance ${var.name}"

  egress {
    cidr_blocks       = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 65535
    protocol          = "tcp"

  }

  ingress {
    cidr_blocks       = [var.cidr_block_private]
    from_port         = 0
    to_port           = 65535
    protocol          = "tcp"
  }
}

# AMI of the latest Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
}

resource "aws_launch_template" "nat_instance" {
  name_prefix = var.name
  image_id    = data.aws_ami.amazon_linux_2.id

  iam_instance_profile {
    arn = aws_iam_instance_profile.nat_instance.arn
  }

  instance_type = "t2.small"

  key_name = "wellcomedigitalstorage"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.nat_instance_egress.id]
    delete_on_termination       = true
  }

  user_data = base64encode(join("\n", [
    "#cloud-config",
    yamlencode({
      # https://cloudinit.readthedocs.io/en/latest/topics/modules.html
      write_files : concat([
        {
          path : "/opt/nat/runonce.sh",
          content : templatefile("${path.module}/runonce.sh", { eni_id = aws_network_interface.nat_instance.id }),
          permissions : "0755",
        },
        {
          path : "/opt/nat/snat.sh",
          content : file("${path.module}/snat.sh"),
          permissions : "0755",
        },
        {
          path : "/etc/systemd/system/snat.service",
          content : file("${path.module}/snat.service"),
        },
      ]),
      runcmd : ["/opt/nat/runonce.sh"],
    })
  ]))

  description = "Launch template for NAT instance ${var.name}"
  tags = {
    Name = "nat-instance-${var.name}"
  }
}

resource "aws_autoscaling_group" "nat_instances" {
  name_prefix         = "nat-${var.name}"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 1

  # Has to be in same subnmet as network interface or error when running
  # runonce.sh on host:
  #
  # An error occurred (InvalidParameterCombination) when calling the AttachNetworkInterface operation: You may not attach a network interface to an instance if they are not in the same availability zone
  vpc_zone_identifier = [module.public_subnets.subnets[0]]

  launch_template {
    id = aws_launch_template.nat_instance.id
    version            = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "nat-instance-${var.name}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "nat_instance" {
  role        = aws_iam_role.nat_instance.name
}

resource "aws_iam_role" "nat_instance" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.nat_instance.name
}

resource "aws_iam_role_policy" "allow_nat_instance_eni" {
  role        = aws_iam_role.nat_instance.name
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachNetworkInterface"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_route" "nat_instance" {
  route_table_id         = module.private_subnets.route_table_id
  destination_cidr_block = "139.162.244.147/32"
  network_interface_id   = aws_network_interface.nat_instance.id
}

