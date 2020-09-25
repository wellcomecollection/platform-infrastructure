locals {
  infra_bucket_arn = data.terraform_remote_state.shared_infra.outputs.infra_bucket_arn

  infra_bucket_id = data.terraform_remote_state.shared_infra.outputs.infra_bucket

  lambda_error_alarm_arn = data.terraform_remote_state.shared_infra.outputs.lambda_error_alarm_arn

  non_critical_slack_webhook = data.aws_ssm_parameter.non_critical_slack_webhook.value

  platform_read_only_role_arn = data.terraform_remote_state.accounts.outputs.platform_read_only_role_arn

  account_ci_role_arn_map = data.terraform_remote_state.accounts.outputs.ci_role_arn

  ci_agent_role_name = "ci-agent"

  ci_vpc_id = data.terraform_remote_state.critical_back_end.outputs.ci_vpc_id
  ci_vpc_private_subnets = data.terraform_remote_state.critical_back_end.outputs.ci_vpc_private_subnets
}