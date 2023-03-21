provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::487094370410:role/systems_strategy-admin"
  }
}

provider "aws" {
  region = "eu-west-1"
  alias  = "platform"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-admin"
  }
}
