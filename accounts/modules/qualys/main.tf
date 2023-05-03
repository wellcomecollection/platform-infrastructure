# These IAM roles are used by the Infosec team in D&T, who use
# vulnerability scanning software from Qualys to gather data about
# EC2 instances.
#
# It's based on https://github.com/wellcometrust/ncw-terraform-modules/blob/a5447056fd50175b47a1243dcb4c3228b9570751/AWS/iam-instance-roles/qualys-iam-role/main.tf

resource "aws_iam_role" "wt-qualys-role" {
  assume_role_policy   = data.aws_iam_policy_document.allow_assume_instance_role.json
  description          = "Allow Qualys vulnerability scanning software in D&T to scan our EC2 instances"
  max_session_duration = 2 * 60 * 60  # 2 hours
  name                 = "wt-qualys-role"
}

# IAM Policy for Qualys Connector - CHG0034045
resource "aws_iam_policy" "wt-qualys-policy" {
  policy      = data.aws_iam_policy_document.allow_read_ec2_details.json
  description = "Allow Qualys vulnerability scanning software in D&T to scan our EC2 instances"
  name        = "wt-qualys-policy"
}

resource "aws_iam_role_policy_attachment" "wt-qualys-policy-attachment" {
  policy_arn = aws_iam_policy.wt-qualys-policy.arn
  role       = aws_iam_role.wt-qualys-role.name
}
