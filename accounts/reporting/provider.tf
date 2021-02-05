provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::269807742353:role/reporting-admin"
  }
}
