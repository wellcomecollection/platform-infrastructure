data "aws_iam_policy_document" "iiif_prod" {
  statement {
    actions = [
      "sns:Publish",
    ]

    resources = [module.iiif_prod.sns_topic_arn, ]

    condition {
      test     = "StringLike"
      variable = "aws:userId"
      values = [
        "${local.dds_workflow_prod}:*",
        "${local.dash_workflow_prod}:*"
      ]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_sns_topic_policy" "iiif_prod" {
  arn    = module.iiif_prod.sns_topic_arn
  policy = data.aws_iam_policy_document.iiif_prod.json
}

data "aws_iam_policy_document" "api_prod" {
  statement {
    actions = [
      "sns:Publish",
    ]

    resources = [module.api_prod.sns_topic_arn, ]

    condition {
      test     = "StringLike"
      variable = "aws:userId"
      values = [
        "${local.dds_workflow_prod}:*",
        "${local.dash_workflow_prod}:*"
      ]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_sns_topic_policy" "api_prod" {
  arn    = module.api_prod.sns_topic_arn
  policy = data.aws_iam_policy_document.api_prod.json
}

data "aws_iam_policy_document" "iiif_stage" {
  statement {
    actions = [
      "sns:Publish",
    ]

    resources = [module.iiif_stage.sns_topic_arn, ]

    condition {
      test     = "StringLike"
      variable = "aws:userId"
      values = [
        "${local.dds_workflow_stage}:*",
        "${local.dash_workflow_stage}:*"
      ]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_sns_topic_policy" "iiif_stage" {
  arn    = module.iiif_stage.sns_topic_arn
  policy = data.aws_iam_policy_document.iiif_stage.json
}

data "aws_iam_policy_document" "api_stage" {
  statement {
    actions = [
      "sns:Publish",
    ]

    resources = [module.api_stage.sns_topic_arn, ]

    condition {
      test     = "StringLike"
      variable = "aws:userId"
      values = [
        "${local.dds_workflow_stage}:*",
        "${local.dds_workflow_test}:*",
        "${local.dash_workflow_stage}:*",
        "${local.dash_workflow_test}:*",
      ]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_sns_topic_policy" "api_stage" {
  arn    = module.api_stage.sns_topic_arn
  policy = data.aws_iam_policy_document.api_stage.json
}

data "aws_iam_policy_document" "iiif_test" {
  statement {
    actions = [
      "sns:Publish",
    ]

    resources = [module.iiif_test.sns_topic_arn, ]

    condition {
      test     = "StringLike"
      variable = "aws:userId"
      values = [
        "${local.dds_workflow_test}:*",
        "${local.dash_workflow_test}:*"
      ]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_sns_topic_policy" "iiif_test" {
  arn    = module.iiif_test.sns_topic_arn
  policy = data.aws_iam_policy_document.iiif_test.json
}
