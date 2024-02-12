data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "awsserviceroleforimagebuilder" {
  assume_role_policy = data.aws_iam_policy_document.assume.json
  name               = "${var.name}-role"
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "imagebuilder" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
  role       = aws_iam_role.awsserviceroleforimagebuilder.name
}
resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.awsserviceroleforimagebuilder.name
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${var.name}-EC2InstanceProfileImageBuilder"
  role = aws_iam_role.awsserviceroleforimagebuilder.name
}

resource "aws_iam_role_policy_attachment" "custom_policy" {
  count      = var.attach_custom_policy ? 1 : 0
  policy_arn = var.custom_policy_arn
  role       = aws_iam_role.awsserviceroleforimagebuilder.name
}

resource "aws_iam_role_policy" "aws_policy" {
  name   = "${var.name}-aws-access"
  role   = aws_iam_role.awsserviceroleforimagebuilder.id
  policy = data.aws_iam_policy_document.aws_policy.json
}

data "aws_iam_policy_document" "aws_policy" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::*:role/EC2ImageBuilderDistributionCrossAccountRole"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2messages:GetMessages",
      "ec2:MetadataHttpEndpoint",
      "ec2:MetadataHttpPutResponseHopLimit",
      "ec2:MetadataHttpTokens",
      "ssm:SendCommand"
    ]
    resources = ["*"]
  }

}