# Although we've declared the provider at the top level, we need to redeclare it in
# the module.  Otherwise, Terraform defaults to "hashicorp/{provider}"
# See https://github.com/hashicorp/terraform/issues/25172#issuecomment-641284286
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    ec = {
      source  = "elastic/ec"
    }
  }
}
