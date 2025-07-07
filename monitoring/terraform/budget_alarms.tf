# create a budget alarm for the aws.platform provider
module "platform_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.platform
  }

  budget_name = "platform-monthly-budget"

  tags = {
    Name        = "platform-budget-alarm"
    Environment = "Production"
    Account     = "Platform"
  }
}

# create a budget alarm for the catalogue account
module "catalogue_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.catalogue
  }

  budget_name = "catalogue-monthly-budget"

  tags = {
    Name        = "catalogue-budget-alarm"
    Environment = "Production"
    Account     = "Catalogue"
  }
}

# create a budget alarm for the data account
module "data_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.data
  }

  budget_name = "data-monthly-budget"

  tags = {
    Name        = "data-budget-alarm"
    Environment = "Production"
    Account     = "Data"
  }
}

# create a budget alarm for the digirati account
module "digirati_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.digirati
  }

  budget_name = "digirati-monthly-budget"

  tags = {
    Name        = "digirati-budget-alarm"
    Environment = "Production"
    Account     = "Digirati"
  }
}

# create a budget alarm for the digitisation account
module "digitisation_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.digitisation
  }

  budget_name = "digitisation-monthly-budget"

  tags = {
    Name        = "digitisation-budget-alarm"
    Environment = "Production"
    Account     = "Digitisation"
  }
}

# create a budget alarm for the experience account
module "experience_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.experience
  }

  budget_name = "experience-monthly-budget"

  tags = {
    Name        = "experience-budget-alarm"
    Environment = "Production"
    Account     = "Experience"
  }
}

# create a budget alarm for the identity account
module "identity_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.identity
  }

  budget_name = "identity-monthly-budget"

  tags = {
    Name        = "identity-budget-alarm"
    Environment = "Production"
    Account     = "Identity"
  }
}

# create a budget alarm for the microsites account
module "microsites_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.microsites
  }

  budget_name = "microsites-monthly-budget"

  tags = {
    Name        = "microsites-budget-alarm"
    Environment = "Production"
    Account     = "Microsites"
  }
}

# create a budget alarm for the reporting account
module "reporting_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.reporting
  }

  budget_name = "reporting-monthly-budget"

  tags = {
    Name        = "reporting-budget-alarm"
    Environment = "Production"
    Account     = "Reporting"
  }
}

# create a budget alarm for the storage account
module "storage_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.storage
  }

  budget_name = "storage-monthly-budget"

  tags = {
    Name        = "storage-budget-alarm"
    Environment = "Production"
    Account     = "Storage"
  }
}

# create a budget alarm for the systems_strategy account
module "systems_strategy_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.systems_strategy
  }

  budget_name = "systems-strategy-monthly-budget"

  tags = {
    Name        = "systems-strategy-budget-alarm"
    Environment = "Production"
    Account     = "Systems Strategy"
  }
}

# create a budget alarm for the workflow account
module "workflow_budget_alarm" {
  source = "./modules/budget_alarm"

  providers = {
    aws = aws.workflow
  }

  budget_name = "workflow-monthly-budget"

  tags = {
    Name        = "workflow-budget-alarm"
    Environment = "Production"
    Account     = "Workflow"
  }
}

