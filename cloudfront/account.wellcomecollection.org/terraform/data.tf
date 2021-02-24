data "terraform_remote_state" "identity" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::770700576653:role/identity-developer"

    bucket = "identity-static-remote-state"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}
