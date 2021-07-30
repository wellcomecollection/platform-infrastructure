terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  alias  = "platform"
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"
  }
}