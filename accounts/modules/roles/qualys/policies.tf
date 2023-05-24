data "aws_iam_policy_document" "allow_assume_instance_role" {
  statement {
    sid = "AllowsQualysToAssumeTheRole"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::805950163170:root"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["UK-332144-3928933756001"]
    }
  }
}

data "aws_iam_policy_document" "allow_read_ec2_details" {
  statement {
    sid = "AllowsToReadEC2Details"

    actions = [
      "ec2:DescribeAddresses",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "organizations:list*",
    ]

    resources = ["*"]
  }
}
