provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::241906670800:role/dam_prototype-admin"
  }
}

provider "aws" {
  region = "eu-west-1"
  alias  = "platform"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-admin"
  }
}
