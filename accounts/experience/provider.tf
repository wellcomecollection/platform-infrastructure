provider "aws" {
  region  = "eu-west-1"
  version = "2.35.0"

  assume_role {
    role_arn = "arn:aws:iam::130871440101:role/experience-admin"
  }
}
