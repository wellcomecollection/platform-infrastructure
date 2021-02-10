terraform {
  required_version = ">= 0.14"

  backend "s3" {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"

    bucket         = "wellcomecollection-platform-infra"
    key            = "terraform/platform-infrastructure/dns.tfstate"
    dynamodb_table = "terraform-locktable"
    region         = "eu-west-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

data "terraform_remote_state" "identity" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::770700576653:role/identity-developer"

    bucket = "identity-static-remote-state"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}
