provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::782179017633:role/microsites-admin"
  }
}

provider "aws" {
  region = "eu-west-1"
  alias  = "platform"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-admin"
  }
}
