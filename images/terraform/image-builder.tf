resource "aws_s3_bucket" "image-builder" {
  bucket = "wellcomecollection-imagebuilder"
}

data "aws_vpc" "platform_ci" {
  id = data.terraform_remote_state.accounts_platform.outputs.ci_vpc_id
}

locals {
  image_builder_aws_region  = "eu-west-1"
  image_builder_vpc_id      = data.aws_vpc.platform_ci.id
  image_builder_subnet_id   = data.terraform_remote_state.accounts_platform.outputs.ci_vpc_private_subnets[0]
  image_builder_source_cidr = [data.aws_vpc.platform_ci.cidr_block]

  # Config for ecs-optimised-x86
  ecs-optimised-x86-image_builder_source_ami_filter = "amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs"
  ecs-optimised-x86-target_account_ids = [
    local.account_ids_map["workflow"],
  ]
}

resource "aws_secretsmanager_secret" "crowdstrike_cid" {
  name = "image-builder/crowdstrike-cid"
}

resource "aws_secretsmanager_secret" "qualys_cid" {
  name = "image-builder/qualys-cid"
}

resource "aws_secretsmanager_secret" "qualys_aid" {
  name = "image-builder/qualys-aid"
}

resource "aws_s3_object" "crowdstrike_agent_component" {
  bucket  = aws_s3_bucket.image-builder.bucket
  key     = "components/crowdstrike-agent.yml"
  content = file("${path.module}/image-builder/components/crowdstrike-agent.yml")
}

resource "aws_imagebuilder_component" "crowdstrike_agent_component" {
  name     = "crowdstrike-agent"
  platform = "Linux"
  uri      = "s3://${aws_s3_bucket.image-builder.bucket}/${aws_s3_object.crowdstrike_agent_component.key}"
  version  = "1.0.7"

  depends_on = [aws_s3_object.crowdstrike_agent_component]
}

data "aws_ami" "source_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = [local.ecs-optimised-x86-image_builder_source_ami_filter]
  }
}

resource "aws_iam_policy" "image_builder_policy" {
  name   = "image_builder_custom_policy"
  policy = data.aws_iam_policy_document.image_builder_policy_document.json
}

data "aws_iam_policy_document" "image_builder_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [aws_s3_bucket.image-builder.arn,
    "${aws_s3_bucket.image-builder.arn}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      aws_secretsmanager_secret.crowdstrike_cid.arn,
      aws_secretsmanager_secret.qualys_cid.arn,
      aws_secretsmanager_secret.qualys_aid.arn
    ]
  }
}

module "ec2-image-builder-ecs-optimised-x86" {
  source               = "./image-builder"
  name                 = "amazon-linux-2-ecs-collection-x86"
  vpc_id               = local.image_builder_vpc_id
  subnet_id            = local.image_builder_subnet_id
  aws_region           = local.image_builder_aws_region
  source_cidr          = local.image_builder_source_cidr
  source_ami_id        = data.aws_ami.source_ami.id
  ami_name             = "amazon-linux-2-ecs-collection-x86"
  ami_description      = "Wellcome Collection Amazon Linux x86 AMI for ECS"
  custom_policy_arn    = aws_iam_policy.image_builder_policy.arn
  attach_custom_policy = true
  recipe_version       = "0.0.8"
  build_component_arn  = [aws_imagebuilder_component.crowdstrike_agent_component.arn]
  target_account_ids   = local.ecs-optimised-x86-target_account_ids
}
