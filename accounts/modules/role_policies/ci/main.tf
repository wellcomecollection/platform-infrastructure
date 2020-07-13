resource "aws_iam_role_policy" "ci_permissions" {
  role   = var.role_name
  policy = data.aws_iam_policy_document.ci_permissions.json
}
