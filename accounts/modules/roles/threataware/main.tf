# These IAM roles are used by the Infosec team in D&T, who use
# vulnerability scanning software from ThreatAware to gather data
# about AWS accounts.
#
# It's based on https://github.com/wellcometrust/ncw-terraform-modules/tree/master/AWS/iam-roles/ta-iam-role

# IAM Role for ThreatAware - CHG0034245
resource "aws_iam_role" "wt-ta-role" {
  assume_role_policy   = data.aws_iam_policy_document.allow_assume_threataware_role.json
  description          = "ThreatAware API Connector to AWS"
  max_session_duration = 7200
  name                 = "ta-app-role"
}

# The IAM role policy attachment comes from the D&T-provisioned role,
# which gives it read-only access to IAM, S3, EC2 and Certificate Manager.
#
# Because our S3 buckets contain Collections material which may be sensitive,
# we explicitly deny the s3:GetObject action -- i.e. the ability to actually
# download objects.
#
# If there is a legitimate need then we can consider allowing access to
# certain objects, but by default I'm not giving that away.

resource "aws_iam_role_policy_attachment" "wt-ta-role-policy-attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/IAMReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AWSCertificateManagerReadOnly",
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  ])

  role       = aws_iam_role.wt-ta-role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "disable_s3_get_object" {
  role   = aws_iam_role.wt-ta-role.id
  policy = data.aws_iam_policy_document.disable_s3_get_object.json
}
