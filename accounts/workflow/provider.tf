provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::299497370133:role/workflow-admin"
  }
}
