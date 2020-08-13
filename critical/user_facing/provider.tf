provider "aws" {
  region  = var.aws_region
  version = "~> 2.7"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-admin"
  }
}

provider "aws" {
  alias = "us-east-1"

  region = "us-east-1"

  version = "~> 2.7"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-admin"
  }
}

data "aws_caller_identity" "current" {}
