locals {
  default_tags = {
    TerraformConfigurationURL = "https://github.com/wellcomecollection/platform-infrastructure/tree/main/monitoring/terraform"
    Department                = "Digital Platform"
    Division                  = "Culture and Society"
    Use                       = "Monitoring"
    Environment               = "Production"
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-admin"
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias  = "platform"
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias = "catalogue"

  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::756629837203:role/catalogue-developer"
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias = "storage"

  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::975596993436:role/storage-developer"
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias = "identity"

  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::770700576653:role/identity-developer"
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias = "workflow"

  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::299497370133:role/workflow-developer"
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"
  }

  default_tags {
    tags = local.default_tags
  }
}
