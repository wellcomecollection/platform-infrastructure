locals {
  default_tags = {
    TerraformConfigurationURL = "https://github.com/wellcomecollection/platform-infrastructure/tree/main/costs_report/terraform"
    Department                = "Digital Platform"
    Division                  = "Culture and Society"
    Use                       = "Costs report"
    Environment               = "Production"
  }
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  region = "eu-west-1"
  alias  = "platform"

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
  alias = "experience"

  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::130871440101:role/experience-developer"
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
  alias = "dam_prototype"

  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::241906670800:role/dam_prototype-developer"
  }

  default_tags {
    tags = local.default_tags
  }
}

provider "aws" {
  alias = "digirati"

  region = "eu-west-1"

  assume_role {
    role_arn = "arn:aws:iam::653428163053:role/digirati-developer"
  }

  default_tags {
    tags = local.default_tags
  }
}
