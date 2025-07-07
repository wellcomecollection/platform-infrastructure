module "platform_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.platform
  }
}

module "catalogue_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.catalogue
  }
}

module "data_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.data
  }
}

module "digirati_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.digirati
  }
}

module "digitisation_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.digitisation
  }
}

module "experience_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.experience
  }
}

module "identity_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.identity
  }
}

module "microsites_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.microsites
  }
}

module "reporting_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.reporting
  }
}

module "storage_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.storage
  }
}

module "systems_strategy_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.systems_strategy
  }
}

module "workflow_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.workflow
  }
}

