resource "aws_security_group" "buildkite" {
  name   = "buildkite-vpc-endpoints"
  vpc_id = local.ci_vpc_id

  tags = {
    Name = "buildkite-vpc-endpoints"
  }

  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # See https://aws.amazon.com/premiumsupport/knowledge-center/ecs-pull-container-api-error-ecr/
  #
  #     If you're using AWS PrivateLink for Amazon ECR, then confirm that
  #     the security group, associated with the interface VPC endpoints
  #     for Amazon ECR, allows inbound traffic over HTTPS (port 443)
  #     from within the security group […].
  #
  ingress {
    description = "Allow ECR access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
