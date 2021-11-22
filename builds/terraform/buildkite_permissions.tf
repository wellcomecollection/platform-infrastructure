data "aws_iam_role" "ci_agent" {
  name = local.ci_agent_role_name
}

resource "aws_iam_role_policy" "ci_agent_get_buildkite_agent_key" {
  policy = data.aws_iam_policy_document.get_buildkite_agent_key.json
  role   = data.aws_iam_role.ci_agent.id
}

resource "aws_iam_role_policy" "ci_agent" {
  policy = data.aws_iam_policy_document.ci_permissions.json
  role   = data.aws_iam_role.ci_agent.id
}

data "aws_iam_role" "ci_nano_agent" {
  name = local.ci_nano_agent_role_name
}

resource "aws_iam_role_policy" "ci_nano_get_buildkite_agent_key" {
  policy = data.aws_iam_policy_document.get_buildkite_agent_key.json
  role   = data.aws_iam_role.ci_nano_agent.id
}

resource "aws_iam_role_policy" "ci_nano_agent" {
  policy = data.aws_iam_policy_document.ci_nano_permissions.json
  role   = data.aws_iam_role.ci_nano_agent.id
}

# These two blocks give the BuildKite autoscaling Lambdas permission
# to retrieve the Buildkite agent key.  These roles are created by
# a nested Buildkite stack and I don't know how to retrieve the role names
# programatically, so I've hard-coded the values here.

resource "aws_iam_role_policy" "lambda_get_buildkite_agent_key" {
  policy = data.aws_iam_policy_document.get_buildkite_agent_key.json
  role   = "buildkite-elasticstack-Autoscaling-1-ExecutionRole-1N5V0S7X6NFLO"
}

resource "aws_iam_role_policy" "lambda_nano_get_buildkite_agent_key" {
  policy = data.aws_iam_policy_document.get_buildkite_agent_key.json
  role   = "buildkite-elasticstack-nano-Autoscal-ExecutionRole-J9JXFW2ZIZA6"
}
