resource "aws_cloudformation_stack" "buildkite" {
  name = "buildkite-elasticstack"

  capabilities = ["CAPABILITY_NAMED_IAM"]

  parameters = {
    BuildkiteAgentToken = data.aws_secretsmanager_secret_version.example.secret_string

    MinSize = 0
    MaxSize = 60

    ScaleDownPeriod     = 300
    ScaleCooldownPeriod = 60

    SpotPrice = 0.05

    ScaleUpAdjustment   = 1
    ScaleDownAdjustment = -10

    AgentsPerInstance                         = 1
    BuildkiteTerminateInstanceAfterJobTimeout = 1800

    RootVolumeSize = 50
    RootVolumeName = "/dev/xvda"
    RootVolumeType = "gp2"

    InstanceType            = "r5.large"
    InstanceCreationTimeout = "PT5M"
    InstanceRoleName        = local.ci_agent_role_name

    VpcId           = local.ci_vpc_id
    Subnets         = join(",", local.ci_vpc_private_subnets)
    SecurityGroupId = aws_security_group.buildkite.id

    AssociatePublicIpAddress = true

    KeyName = "wellcomedigitalplatform"

    CostAllocationTagName  = "aws:createdBy"
    CostAllocationTagValue = "buildkite-elasticstack"

    BuildkiteQueue                                            = "default"
    BuildkiteAgentRelease                                     = "stable"
    BuildkiteAgentTimestampLines                              = false
    BuildkiteTerminateInstanceAfterJobDecreaseDesiredCapacity = true

    # We don't have to terminate an agent after a job completes.  We have
    # an agent hook (see buildkite_agent_hook.sh) which tries to clean up
    # any state left over from previous jobs, so each instance will be "fresh",
    # but already have a local cache of Docker images and Scala libraries.
    BuildkiteTerminateInstanceAfterJob = false

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

# This is a separate pool of Buildkite instances specifically meant
# for long-running, low-compute tasks.
#
# e.g. waiting for a weco-deploy build to finish.
#
# I picked the name "nano" because they're a catchall group for any sort
# of small task, rather than for a specific purpose.
#
# You can target this queue by adding the following lines to the
# Buildkite steps:
#
#      agents:
#        queue: "nano"
#
resource "aws_cloudformation_stack" "buildkite_nano" {
  name = "buildkite-elasticstack-nano"

  capabilities = ["CAPABILITY_NAMED_IAM"]

  parameters = {
    # At time of writing (1 October 2021), we have six deployment tasks
    # in the pipeline repo: four adapters, the reindexer, and the pipeline.
    #
    # We want all of these to run simultaneously and leave room for other
    # nano tasks, so we need >6 instances.
    MinSize = 0
    MaxSize = 10

    SpotPrice    = 0.01
    InstanceType = "t3.nano"

    BuildkiteQueue = "nano"

    BuildkiteAgentToken = data.aws_secretsmanager_secret_version.example.secret_string

    ScaleDownPeriod     = 300
    ScaleCooldownPeriod = 60

    ScaleUpAdjustment   = 1
    ScaleDownAdjustment = -10

    AgentsPerInstance                         = 1
    BuildkiteTerminateInstanceAfterJobTimeout = 300

    RootVolumeSize = 25
    RootVolumeName = "/dev/xvda"
    RootVolumeType = "gp2"

    InstanceCreationTimeout = "PT5M"
    InstanceRoleName        = local.ci_nano_agent_role_name

    VpcId           = local.ci_vpc_id
    Subnets         = join(",", local.ci_vpc_private_subnets)
    SecurityGroupId = aws_security_group.buildkite.id

    AssociatePublicIpAddress = true

    KeyName = "wellcomedigitalplatform"

    CostAllocationTagName  = "aws:createdBy"
    CostAllocationTagValue = "buildkite-elasticstack"

    BuildkiteAgentRelease                                     = "stable"
    BuildkiteAgentTimestampLines                              = false
    BuildkiteTerminateInstanceAfterJobDecreaseDesiredCapacity = true

    # We don't have to terminate an agent after a job completes.  We have
    # an agent hook (see buildkite_agent_hook.sh) which tries to clean up
    # any state left over from previous jobs, so each instance will be "fresh",
    # but already have a local cache of Docker images and Scala libraries.
    BuildkiteTerminateInstanceAfterJob = false

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

data "aws_iam_role" "ci_nano_agent" {
  name = local.ci_nano_agent_role_name
}

resource "aws_iam_role_policy" "ci_nano_agent" {
  policy = data.aws_iam_policy_document.ci_permissions.json
  role   = data.aws_iam_role.ci_nano_agent.id

  provider = aws
}

data "aws_iam_policy_document" "ci_permissions" {
  statement {
    actions = ["sts:AssumeRole"]
    resources = [
      local.platform_read_only_role_arn,
      local.account_ci_role_arn_map["platform"],
      local.account_ci_role_arn_map["catalogue"],
      local.account_ci_role_arn_map["digirati"],
      local.account_ci_role_arn_map["storage"],
      local.account_ci_role_arn_map["experience"],
      local.account_ci_role_arn_map["workflow"],
      local.account_ci_role_arn_map["identity"],
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

      # Allow BuildKite to get read-only credentials for the pipeline
      # cluster, to help with auto-deployment of the pipeline.
      "arn:aws:secretsmanager:${var.aws_region}:${local.account_id}:secret:elasticsearch/pipeline_storage_*/read_only*",

      "arn:aws:secretsmanager:${var.aws_region}:${local.account_id}:secret:elasticsearch/pipeline_storage_*/public_host*",

      # Allow BuildKite to get storage service credentials so it can send
      # test bags in the storage service repo.
      "arn:aws:secretsmanager:${var.aws_region}:${local.account_id}:secret:buildkite/storage_service*",
    ]
  }

  # Publish & retrieve scala libraries
  statement {
    actions = [
      "s3:*"
    ]

    resources = [
      "${aws_s3_bucket.releases.arn}/weco/*",
    ]
  }

  # Publish & retrieve lambdas
  statement {
    actions = [
      "s3:*"
    ]

    resources = [
      "${local.infra_bucket_arn}/lambdas/*",
    ]

  }
}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

# Upload an agent environment hook to /env in the secrets bucket.
#
# This will be downloaded by the agent before the start of each job.
# The hook cleans up the environment, so any stale state left from a previous
# job shouldn't pollute the job that's running now.
#
# See:
# https://github.com/buildkite/elastic-ci-stack-for-aws#build-secrets
# https://buildkite.com/docs/agent/v3/hooks
locals {
  buildkite_agent_hook_path = "${path.module}/../buildkite_agent_hook.sh"
}

resource "aws_s3_bucket_object" "buildkite_agent_hook" {
  bucket = aws_cloudformation_stack.buildkite.outputs["ManagedSecretsBucket"]
  key    = "env"
  source = local.buildkite_agent_hook_path
  etag   = filemd5(local.buildkite_agent_hook_path)
}

resource "aws_s3_bucket_object" "buildkite_nano_agent_hook" {
  bucket = aws_cloudformation_stack.buildkite_nano.outputs["ManagedSecretsBucket"]
  key    = "env"
  source = local.buildkite_agent_hook_path
  etag   = filemd5(local.buildkite_agent_hook_path)
}
