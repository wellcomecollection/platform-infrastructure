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

  # Config for amzn2-ecs-optimised-hvm-x86_64-ebs
  amzn2-ecs-optimised-hvm-x86_64-ebs-image_builder_source_ami_filter = "amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs"
  amzn2-ecs-optimised-hvm-x86_64-ebs-target_account_ids = [
    local.account_ids_map["workflow"],
    local.account_ids_map["digirati"],
  ]

  # Config for amzn2-hvm-x86_64-gp2
  amzn2-hvm-x86_64-gp2-image_builder_source_ami_filter = "amzn2-ami-hvm-2.0.*-x86_64-gp2"
  amzn2-hvm-x86_64-gp2-target_account_ids = [
    local.account_ids_map["workflow"],
    local.account_ids_map["digirati"],
  ]
}

# secrets needed for image-builder to apply components
resource "aws_secretsmanager_secret" "crowdstrike_cid" {
  name = "image-builder/crowdstrike-cid"
}

resource "aws_secretsmanager_secret" "qualys_cid" {
  name = "image-builder/qualys-cid"
}

resource "aws_secretsmanager_secret" "qualys_aid" {
  name = "image-builder/qualys-aid"
}

resource "aws_secretsmanager_secret" "qualys_uri" {
  name = "image-builder/qualys-uri"
}

# crowdstrike agent
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

# qualys agent
resource "aws_s3_object" "qualys_agent_component" {
  bucket  = aws_s3_bucket.image-builder.bucket
  key     = "components/qualys-agent.yml"
  content = file("${path.module}/image-builder/components/qualys-agent.yml")
}

resource "aws_imagebuilder_component" "qualys_agent_component" {
  name     = "qualys-agent"
  platform = "Linux"
  uri      = "s3://${aws_s3_bucket.image-builder.bucket}/${aws_s3_object.qualys_agent_component.key}"
  version  = "1.0.1"

  depends_on = [aws_s3_object.qualys_agent_component]
}


# iam policy for image builder instance
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
      aws_secretsmanager_secret.qualys_aid.arn,
      aws_secretsmanager_secret.qualys_uri.arn,
    ]
  }
}


# amzn2-ecs-optimised-hvm-x86_64-ebs
data "aws_ami" "amzn2-ecs-optimised-hvm-x86_64-ebs" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = [local.amzn2-ecs-optimised-hvm-x86_64-ebs-image_builder_source_ami_filter]
  }
}

module "ec2-image-builder-amzn2-ecs-optimised-hvm-x86_64-ebs" {
  source               = "./image-builder"
  name                 = "weco-amzn2-ecs-optimised-hvm-x86_64"
  vpc_id               = local.image_builder_vpc_id
  subnet_id            = local.image_builder_subnet_id
  aws_region           = local.image_builder_aws_region
  source_cidr          = local.image_builder_source_cidr
  source_ami_id        = data.aws_ami.amzn2-ecs-optimised-hvm-x86_64-ebs.id
  ami_name             = "weco-amzn2-ecs-optimised-hvm-x86_64"
  ami_description      = "Wellcome Collection: Amazon Linux 2, ECS Optimised, HVM, x86_64, GP2"
  custom_policy_arn    = aws_iam_policy.image_builder_policy.arn
  attach_custom_policy = true
  recipe_version       = "1.0.1"
  build_component_arn = [
    aws_imagebuilder_component.crowdstrike_agent_component.arn,
    aws_imagebuilder_component.qualys_agent_component.arn,
  ]
  target_account_ids = local.amzn2-ecs-optimised-hvm-x86_64-ebs-target_account_ids
}

# amzn2-hvm-x86_64-gp2
data "aws_ami" "amzn2-hvm-x86_64-gp2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = [local.amzn2-hvm-x86_64-gp2-image_builder_source_ami_filter]
  }
}

module "ec2-image-builder-amzn2-hvm-x86_64-gp2" {
  source               = "./image-builder"
  name                 = "weco-amzn2-hvm-x86_64-gp2"
  vpc_id               = local.image_builder_vpc_id
  subnet_id            = local.image_builder_subnet_id
  aws_region           = local.image_builder_aws_region
  source_cidr          = local.image_builder_source_cidr
  source_ami_id        = data.aws_ami.amzn2-hvm-x86_64-gp2.id
  ami_name             = "weco-amzn2-hvm-x86_64-gp2"
  ami_description      = "Wellcome Collection: Amazon Linux 2, HVM, x86_64, GP2"
  custom_policy_arn    = aws_iam_policy.image_builder_policy.arn
  attach_custom_policy = true
  recipe_version       = "1.0.1"
  build_component_arn = [
    aws_imagebuilder_component.crowdstrike_agent_component.arn,
    aws_imagebuilder_component.qualys_agent_component.arn,
  ]
  target_account_ids = local.amzn2-hvm-x86_64-gp2-target_account_ids
}