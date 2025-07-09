module "platform_budget_alarm" {
  source = "./modules/budget_alarm"

  account_name = "platform"

  providers = {
    aws = aws.platform
  }
}

module "catalogue_budget_alarm" {
  source = "./modules/budget_alarm"

  account_name = "catalogue"

  providers = {
    aws = aws.catalogue
  }
}

module "data_budget_alarm" {
  source = "./modules/budget_alarm"

  account_name = "data"

  providers = {
    aws = aws.data
  }
}

module "digirati_budget_alarm" {
  source = "./modules/budget_alarm"

  account_name = "digirati"

  providers = {
    aws = aws.digirati
  }
}

module "digitisation_budget_alarm" {
  source = "./modules/budget_alarm"

  account_name = "digitisation"

  providers = {
    aws = aws.digitisation
  }
}

module "experience_budget_alarm" {
  source = "./modules/budget_alarm"

  account_name = "experience"

  providers = {
    aws = aws.experience
  }
}

module "identity_budget_alarm" {
  source = "./modules/budget_alarm"

  account_name = "identity"

  providers = {
    aws = aws.identity
  }
}

module "microsites_budget_alarm" {
  source = "./modules/budget_alarm"

  account_name = "microsites"

  providers = {
    aws = aws.microsites
  }
}

module "reporting_budget_alarm" {
  source = "./modules/budget_alarm"

  account_name = "reporting"

  providers = {
    aws = aws.reporting
  }
}

module "storage_budget_alarm" {
  source = "./modules/budget_alarm"

  account_name = "storage"

  providers = {
    aws = aws.storage
  }
}

module "systems_strategy_budget_alarm" {
  source = "./modules/budget_alarm"

  account_name = "systems_strategy"

  providers = {
    aws = aws.systems_strategy
  }
}

module "workflow_budget_alarm" {
  source = "./modules/budget_alarm"

  account_name = "workflow"

  providers = {
    aws = aws.workflow
  }
}

