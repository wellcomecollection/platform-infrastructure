terraform {
  backend "s3" {
    bucket         = "wellcomecollection-platform-infra"
    key            = "terraform/platform-infrastructure/accounts/microsites.tfstate"
    dynamodb_table = "terraform-locktable"

    role_arn = "arn:aws:iam::760097843905:role/platform-developer"
    region   = "eu-west-1"
  }
}
