provider "aws" {
  region  = "eu-west-1"
  version = "2.35.0"

  assume_role {
    role_arn = "arn:aws:iam::653428163053:role/digirati-admin"
  }
}

provider "aws" {
  region  = "eu-west-1"
  version = "2.35.0"
  alias   = "platform"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-admin"
  }
}
