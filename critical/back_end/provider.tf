provider "aws" {
  region = local.aws_region

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"
  }
}

provider "aws" {
  alias  = "storage"
  region = local.aws_region

  assume_role {
    role_arn = "arn:aws:iam::975596993436:role/storage-developer"
  }
}

provider "aws" {
  alias  = "catalogue"
  region = local.aws_region

  assume_role {
    role_arn = "arn:aws:iam::756629837203:role/catalogue-developer"
  }
}

provider "aws" {
  alias  = "experience"
  region = local.aws_region

  assume_role {
    role_arn = "arn:aws:iam::130871440101:role/experience-developer"
  }
}

provider "aws" {
  alias  = "workflow"
  region = local.aws_region

  assume_role {
    role_arn = "arn:aws:iam::299497370133:role/workflow-developer"
  }
}

provider "aws" {
  alias  = "identity"
  region = local.aws_region

  assume_role {
    role_arn = "arn:aws:iam::770700576653:role/identity-developer"
  }
}

provider "aws" {
  alias = "digirati"

  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::653428163053:role/digirati-admin"
  }
}