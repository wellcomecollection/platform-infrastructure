provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::975596993436:role/storage-admin"
  }
}
