resource "aws_cloudformation_stack" "buildkite" {
  name = "buildkite-elasticstack"

  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]

  parameters = {
    MinSize = 0
    MaxSize = 60

    SpotPrice    = 0.05
    InstanceType = "r5.large"

    BuildkiteQueue = "default"

    # This setting tells Buildkite that:
    #
    #   - it should turn off an instance if it's idle for 10 minutes (=600s)
    #   - it should pre-emptively start instances for jobs that are behind
    #     a 'wait' step
    #
    # This is a new feature we got when we updated to v5.7.2 of the
    # CloudFormation template (22 November 2021).  I'm enabling it to see
    # if it makes a difference in Scala repos where we do one autoformat step
    # and then fan out to the main build.
    #
    ScaleOutForWaitingJobs = true
    ScaleInIdlePeriod      = 600

    # We don't have to terminate an agent after a job completes.  We have
    # an agent hook (see buildkite_agent_hook.sh) which tries to clean up
    # any state left over from previous jobs, so each instance will be "fresh",
    # but already have a local cache of Docker images and Scala libraries.
    BuildkiteTerminateInstanceAfterJob = false

    InstanceRoleName = local.ci_agent_role_name

    RootVolumeSize = 25
    RootVolumeName = "/dev/xvda"
    RootVolumeType = "gp2"

    # This is a collection of settings that should be the same for every
    # instance of the Buildkite stack.
    AgentsPerInstance = 1

    BuildkiteAgentToken = data.aws_secretsmanager_secret_version.buildkite_agent_key.secret_string

    InstanceCreationTimeout = "PT5M"

    VpcId           = local.ci_vpc_id
    Subnets         = join(",", local.ci_vpc_private_subnets)
    SecurityGroupId = aws_security_group.buildkite.id

    CostAllocationTagName  = "aws:createdBy"
    CostAllocationTagValue = "buildkite-elasticstack"

    BuildkiteAgentRelease        = "stable"
    BuildkiteAgentTimestampLines = false
  }

  template_body = file("${path.module}/buildkite-v5.7.2.yml")
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

  capabilities = ["CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]

  parameters = {
    SpotPrice    = 0.01
    InstanceType = "t3.nano"

    BuildkiteQueue = "nano"

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

    # This setting would tell Buildkite to scale out for steps behind wait
    # steps.
    #
    # We don't enable it for nano instances because these are often waiting
    # behind long-running tasks in the large queue (e.g. build and publish
    # a Docker image, then deploy it from a nano instance) and the pre-emptively
    # scaled instances would likely time out before they were used.
    #
    ScaleOutForWaitingJobs = false

    # We don't have to terminate an agent after a job completes.  We have
    # an agent hook (see buildkite_agent_hook.sh) which tries to clean up
    # any state left over from previous jobs, so each instance will be "fresh",
    # but already have a local cache of Docker images and Scala libraries.
    BuildkiteTerminateInstanceAfterJob = false

    InstanceRoleName = local.ci_nano_agent_role_name

    RootVolumeSize = 10
    RootVolumeName = "/dev/xvda"
    RootVolumeType = "gp2"

    # This is a collection of settings that should be the same for every
    # instance of the Buildkite stack.
    AgentsPerInstance = 1

    BuildkiteAgentToken = data.aws_secretsmanager_secret_version.buildkite_agent_key.secret_string

    InstanceCreationTimeout = "PT5M"

    VpcId           = local.ci_vpc_id
    Subnets         = join(",", local.ci_vpc_private_subnets)
    SecurityGroupId = aws_security_group.buildkite.id

    CostAllocationTagName  = "aws:createdBy"
    CostAllocationTagValue = "buildkite-elasticstack"

    BuildkiteAgentRelease        = "stable"
    BuildkiteAgentTimestampLines = false
  }

  template_body = file("${path.module}/buildkite-v5.7.2.yml")
}
