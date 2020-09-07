provider "aws" {
  region  = var.aws_region
  version = "~> 2.7"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"
  }
}

provider "aws" {
  alias = "catalogue"

  region  = "eu-west-1"
  version = "2.35.0"

  assume_role {
    role_arn = "arn:aws:iam::756629837203:role/catalogue-admin"
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"
  }
}
