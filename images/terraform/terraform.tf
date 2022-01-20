# Terraform config

terraform {
  backend "s3" {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"

    bucket         = "wellcomecollection-platform-infra"
    key            = "terraform/nginx.tfstate"
    dynamodb_table = "terraform-locktable"
    region         = "eu-west-1"
  }
}

data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"
  }
}

# ECR Public has to be managed in the us-east-1 region.  This isn't made
# super clear by the AWS documentation; the best reference I can find is
# https://docs.aws.amazon.com/AmazonECR/latest/public/getting-started-cli.html#cli-authenticate-registry
provider "aws" {
  region = "us-east-1"
  alias  = "ecr_public"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"
  }
}
