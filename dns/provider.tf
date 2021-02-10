provider "aws" {
  region  = "eu-west-1"
  
  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-admin"
  }
}

provider "aws" {
  region  = "eu-west-1"
  alias   = "dns"
  
  assume_role {
    role_arn = "arn:aws:iam::267269328833:role/wellcomecollection-assume_role_hosted_zone_update"
  }
}
