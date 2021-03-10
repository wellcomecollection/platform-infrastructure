terraform {
  required_providers {
    ec = {
      source  = "elastic/ec"
      version = "0.1.0-beta"
    }
  }
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"
  }
}

provider "ec" {}
