terraform {
  backend "s3" {
    role_arn = "arn:aws:iam::404315009621:role/digitisation-developer"

    bucket         = "wellcomedigitisation-infra"
    key            = "terraform/platform-infrastructure/digitisation_infra.tfstate"
    dynamodb_table = "terraform-locktable"
    region         = "eu-west-1"
  }
}
