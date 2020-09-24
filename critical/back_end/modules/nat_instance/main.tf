resource "aws_security_group" "nat_instance" {
  vpc_id      = var.vpc_id
  description = "Security group for NAT instance ${var.name}"

  tags = {
    Name = "nat-${var.name}"
  }

  egress {
    cidr_blocks       = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
  }

  ingress {
    cidr_blocks       = [var.cidr_block_private]
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
  }
}

resource "aws_network_interface" "nat_instance" {
  security_groups   = [aws_security_group.nat_instance.id]
  subnet_id         = var.public_subnet
  source_dest_check = false
  description       = "ENI for NAT instance ${var.name}"

  tags = {
    Name = "nat-${var.name}"
  }
}

resource "aws_eip" "nat_instance" {
  network_interface = aws_network_interface.nat_instance.id

  tags = {
    Name = "nat-${var.name}"
  }
}

resource "aws_route" "nat_instance" {
  route_table_id         = var.private_subnet_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.nat_instance.id
}

# AMI of the latest Amazon Linux 2
data "aws_ami" "nat_instance" {
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
  image_id    = data.aws_ami.nat_instance.id

  iam_instance_profile {
    arn = aws_iam_instance_profile.nat_instance.arn
  }

  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.nat_instance.id]
    delete_on_termination       = true
  }

  user_data = base64encode(join("\n", [
    "#cloud-config",
    yamlencode({
      # https://cloudinit.readthedocs.io/en/latest/topics/modules.html
      write_files : [
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
      ],
      runcmd : ["/opt/nat/runonce.sh"],
    })
  ]))

  description = "Launch template for NAT instance ${var.name}"
  tags = {
    Name = "nat-instance-${var.name}"
  }
}

resource "aws_autoscaling_group" "nat_instance" {
  name_prefix         = var.name
  desired_capacity    = 1
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = [var.public_subnet]

  launch_template {
    id      = aws_launch_template.nat_instance.id
    version = "$Latest"
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
  name_prefix = var.name
  role        = aws_iam_role.nat_instance.name
}

resource "aws_iam_role" "nat_instance" {
  assume_role_policy = data.aws_iam_policy_document.allow_assume_sts_role.json
}

data "aws_iam_policy_document" "allow_assume_sts_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.nat_instance.name
}

resource "aws_iam_role_policy" "eni" {
  role   = aws_iam_role.nat_instance.name
  policy = data.aws_iam_policy_document.allow_attach_network_interface.json
}

data "aws_iam_policy_document" "allow_attach_network_interface" {
  statement {
    actions = [
      "ec2:AttachNetworkInterface",
    ]

    resources = [
      "*",
    ]
  }
}
