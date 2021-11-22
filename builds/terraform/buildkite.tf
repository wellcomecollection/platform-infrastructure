resource "aws_cloudformation_stack" "buildkite" {
  name = "buildkite-elasticstack"

  capabilities = ["CAPABILITY_NAMED_IAM"]

  parameters = {
    BuildkiteAgentToken = data.aws_secretsmanager_secret_version.buildkite_agent_key.secret_string

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
    #
    # We always run at least one nano instance because nano instances are
    # extremely cheap, and this means the initial "pipeline upload" step
    # is always warm.  An on-demand t3.nano costs ~$4 a month, and we use
    # spot pricing, so this is unlikely to be an issue.
    MinSize = 1
    MaxSize = 10

    SpotPrice    = 0.01
    InstanceType = "t3.nano"

    BuildkiteQueue = "nano"

    BuildkiteAgentToken = data.aws_secretsmanager_secret_version.buildkite_agent_key.secret_string

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

    EnableECRPlugin                 = true
    EnableSecretsPlugin             = true
    EnableDockerLoginPlugin         = true
    EnableCostAllocationTags        = false
    EnableDockerExperimental        = false
    EnableAgentGitMirrorsExperiment = false
    EnableDockerUserNamespaceRemap  = false
  }

  template_body = file("${path.module}/buildkite-v5.7.2.yml")
}
