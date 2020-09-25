resource "aws_cloudformation_stack" "buildkite" {
  name = "buildkite-elasticstack"

  capabilities = ["CAPABILITY_NAMED_IAM"]

  parameters = {
    BuildkiteAgentToken = data.aws_secretsmanager_secret_version.example.secret_string

    MinSize = 0
    MaxSize = 30

    ScaleDownPeriod     = 300
    ScaleCooldownPeriod = 60

    SpotPrice = 0.04

    ScaleUpAdjustment   = 1
    ScaleDownAdjustment = -10

    AgentsPerInstance                         = 1
    BuildkiteTerminateInstanceAfterJobTimeout = 1800

    RootVolumeSize = 250
    RootVolumeName = "/dev/xvda"
    RootVolumeType = "gp2"

    InstanceType            = "r5.large"
    InstanceCreationTimeout = "PT5M"
    InstanceRoleName        = local.ci_agent_role_name

    VpcId   = local.ci_vpc_id
    Subnets = join(",", local.ci_vpc_private_subnets)

    AssociatePublicIpAddress = true

    KeyName = "wellcomedigitalplatform"

    CostAllocationTagName  = "aws:createdBy"
    CostAllocationTagValue = "buildkite-elasticstack"

    BuildkiteQueue                                            = "default"
    BuildkiteAgentRelease                                     = "stable"
    BuildkiteAgentTimestampLines                              = false
    BuildkiteTerminateInstanceAfterJob                        = true
    BuildkiteTerminateInstanceAfterJobDecreaseDesiredCapacity = true

    EnableExperimentalLambdaBasedAutoscaling = true
    EnableECRPlugin                          = true
    EnableSecretsPlugin                      = true
    EnableDockerLoginPlugin                  = true
    EnableCostAllocationTags                 = false
    EnableDockerExperimental                 = false
    EnableAgentGitMirrorsExperiment          = false
    EnableDockerUserNamespaceRemap           = false

  }

  template_body = file("${path.module}/buildkite.yaml")
}

data "aws_iam_role" "ci_agent" {
  name = local.ci_agent_role_name
}

resource "aws_iam_role_policy" "ci_agent" {
  policy = data.aws_iam_policy_document.ci_permissions.json
  role   = data.aws_iam_role.ci_agent.id

  provider = aws
}

data "aws_iam_policy_document" "ci_permissions" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      local.platform_read_only_role_arn,
      local.account_ci_role_arn_map["platform"],
      local.account_ci_role_arn_map["catalogue"],
      local.account_ci_role_arn_map["storage"],
      local.account_ci_role_arn_map["experience"]
    ]
  }

  # Deploy images to ECR (platform account)
  statement {
    actions = [
      "ecr:*",
    ]

    resources = [
      "*",
    ]
  }

  # Retrieve build secrets
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      "arn:aws:secretsmanager:${var.aws_region}:${local.account_id}:secret:builds/*",
    ]
  }

  # Publish & retrieve scala libraries
  dynamic "statement" {
    for_each = [
      "json",
      "storage",
      "monitoring",
      "messaging",
      "fixtures",
      "typesafe_app",
      "sierra-streams-source"
    ]

    content {
      actions = [
        "s3:*"
      ]

      resources = [
        "${aws_s3_bucket.releases.arn}/uk/ac/wellcome/${statement.value}_2.12/*",
        "${aws_s3_bucket.releases.arn}/uk/ac/wellcome/${statement.value}_typesafe_2.12/*",
      ]
    }
  }
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}