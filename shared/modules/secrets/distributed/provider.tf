provider "aws" {
  alias   = "platform"
  region  = var.region
  version = "~> 2.7"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"
  }
}