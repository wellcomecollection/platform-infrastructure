module "super_dev_roleset" {
  source = "../modules/roleset"

  name = "platform-superdev"

  federated_principal = module.account_federation.principal
  aws_principal       = local.aws_principal

  # 4 hours
  max_session_duration_in_seconds = 4 * 60 * 60

  assumable_role_arns = [
    # Platform
    module.aws_account.admin_role_arn,
    module.aws_account.developer_role_arn,
    module.aws_account.read_only_role_arn,

    # Identity
    local.identity_account_roles["admin_role_arn"],
    local.identity_account_roles["developer_role_arn"],
    local.identity_account_roles["read_only_role_arn"],

    # Workflow
    local.workflow_account_roles["admin_role_arn"],
    local.workflow_account_roles["developer_role_arn"],
    local.workflow_account_roles["read_only_role_arn"],

    local.workflow_account_roles["workflow_support_role_arn"],

    # Digirati
    local.digirati_account_roles["admin_role_arn"],
    local.digirati_account_roles["developer_role_arn"],
    local.digirati_account_roles["read_only_role_arn"],

    # Storage
    local.storage_account_roles["admin_role_arn"],
    local.storage_account_roles["developer_role_arn"],
    local.storage_account_roles["read_only_role_arn"],

    # Experience
    local.experience_account_roles["admin_role_arn"],
    local.experience_account_roles["developer_role_arn"],
    local.experience_account_roles["read_only_role_arn"],

    # Data
    local.data_account_roles["developer_role_arn"],
    local.data_account_roles["read_only_role_arn"],
    local.data_account_roles["admin_role_arn"],

    # Reporting
    local.reporting_account_roles["developer_role_arn"],
    local.reporting_account_roles["read_only_role_arn"],
    local.reporting_account_roles["admin_role_arn"],

    # Digitisation
    local.digitisation_account_roles["developer_role_arn"],
    local.digitisation_account_roles["read_only_role_arn"],
    local.digitisation_account_roles["admin_role_arn"],

    # Catalogue
    local.catalogue_account_roles["developer_role_arn"],
    local.catalogue_account_roles["read_only_role_arn"],
    local.catalogue_account_roles["admin_role_arn"],

    # DAM Prototype
    local.dam_prototype_account_roles["developer_role_arn"],
    local.dam_prototype_account_roles["read_only_role_arn"],
    local.dam_prototype_account_roles["admin_role_arn"],

    # CI Roles
    local.ci_agent_role_arn,
    module.aws_account.publisher_role_arn,
    module.aws_account.ci_role_arn,
    local.catalogue_account_roles["ci_role_arn"],
    local.data_account_roles["ci_role_arn"],
    local.digirati_account_roles["ci_role_arn"],
    local.reporting_account_roles["ci_role_arn"],
    local.storage_account_roles["ci_role_arn"],
    local.data_account_roles["ci_role_arn"],
    local.workflow_account_roles["ci_role_arn"],
    local.identity_account_roles["ci_role_arn"],
    local.digitisation_account_roles["ci_role_arn"],
    local.experience_account_roles["ci_role_arn"],
    local.dam_prototype_account_roles["ci_role_arn"],

    aws_iam_role.s3_scala_releases_read.arn,

    # Route 53
    "arn:aws:iam::267269328833:role/wellcomecollection-assume_role_hosted_zone_update",
  ]
}

module "dev_roleset" {
  source = "../modules/roleset"

  name = "platform-dev"

  federated_principal = module.account_federation.principal
  aws_principal       = local.aws_principal

  assumable_role_arns = [
    # Platform
    module.aws_account.developer_role_arn,
    module.aws_account.read_only_role_arn,

    # Identity
    local.identity_account_roles["developer_role_arn"],
    local.identity_account_roles["read_only_role_arn"],

    # Digirati
    local.digirati_account_roles["developer_role_arn"],
    local.digirati_account_roles["read_only_role_arn"],

    # Workflow
    local.workflow_account_roles["developer_role_arn"],
    local.workflow_account_roles["read_only_role_arn"],

    # Storage
    local.storage_account_roles["developer_role_arn"],
    local.storage_account_roles["read_only_role_arn"],

    # Experience
    local.experience_account_roles["developer_role_arn"],
    local.experience_account_roles["read_only_role_arn"],

    # Data
    local.data_account_roles["developer_role_arn"],
    local.data_account_roles["read_only_role_arn"],

    # Reporting
    local.reporting_account_roles["developer_role_arn"],
    local.reporting_account_roles["read_only_role_arn"],

    # Catalogue
    local.catalogue_account_roles["developer_role_arn"],
    local.catalogue_account_roles["read_only_role_arn"],

    # Digitisation
    local.digitisation_account_roles["developer_role_arn"],
    local.digitisation_account_roles["read_only_role_arn"],

    # Scala lib read Role
    aws_iam_role.s3_scala_releases_read.arn,

    # CI Roles
    local.ci_agent_role_arn,
    module.aws_account.publisher_role_arn,
    module.aws_account.ci_role_arn,
    local.catalogue_account_roles["ci_role_arn"],
    local.data_account_roles["ci_role_arn"],
    local.digirati_account_roles["ci_role_arn"],
    local.reporting_account_roles["ci_role_arn"],
    local.storage_account_roles["ci_role_arn"],
    local.workflow_account_roles["ci_role_arn"],
    local.digitisation_account_roles["ci_role_arn"],
    local.experience_account_roles["ci_role_arn"],
  ]
}

module "storage_dev_roleset" {
  source = "../modules/roleset"

  name = "storage-dev"

  federated_principal = module.account_federation.principal
  aws_principal       = local.aws_principal

  assumable_role_arns = [
    # Platform
    module.aws_account.read_only_role_arn,

    # Workflow
    local.workflow_account_roles["developer_role_arn"],
    local.workflow_account_roles["read_only_role_arn"],

    # Digirati
    local.digirati_account_roles["developer_role_arn"],
    local.digirati_account_roles["read_only_role_arn"],

    # Storage
    local.storage_account_roles["developer_role_arn"],
    local.storage_account_roles["read_only_role_arn"],

    # Scala lib read Role
    aws_iam_role.s3_scala_releases_read.arn,
  ]
}

module "workflow_dev_roleset" {
  source = "../modules/roleset"

  name = "workflow-dev"

  federated_principal = module.account_federation.principal
  aws_principal       = local.aws_principal

  assumable_role_arns = [
    # Workflow
    local.workflow_account_roles["admin_role_arn"],
    local.workflow_account_roles["developer_role_arn"],
    local.workflow_account_roles["read_only_role_arn"],

    local.workflow_account_roles["workflow_support_role_arn"],
  ]
}

module "data_analyst_roleset" {
  source = "../modules/roleset"

  name = "data-analyst"

  federated_principal = module.account_federation.principal
  aws_principal       = local.aws_principal

  assumable_role_arns = [
    module.aws_account.read_only_role_arn,
    local.experience_account_roles["read_only_role_arn"],
    local.workflow_account_roles["read_only_role_arn"],

    local.storage_account_roles["read_only_role_arn"],
    local.reporting_account_roles["read_only_role_arn"],
    local.data_account_roles["read_only_role_arn"],
  ]
}

module "data_dev_roleset" {
  source = "../modules/roleset"

  name = "data-dev"

  federated_principal = module.account_federation.principal
  aws_principal       = local.aws_principal

  assumable_role_arns = [
    # Platform
    # Currently the admin role is needed as we have a lot of
    # infra in the platform account that should be in the catalogue account
    module.aws_account.admin_role_arn,
    module.aws_account.developer_role_arn,
    module.aws_account.read_only_role_arn,
    module.aws_account.ci_role_arn,

    # Data
    local.data_account_roles["admin_role_arn"],
    local.data_account_roles["developer_role_arn"],
    local.data_account_roles["read_only_role_arn"],
    local.data_account_roles["ci_role_arn"],

    # Reporting
    local.reporting_account_roles["developer_role_arn"],
    local.reporting_account_roles["read_only_role_arn"],
    local.reporting_account_roles["ci_role_arn"],

    # Catalogue
    local.catalogue_account_roles["developer_role_arn"],
    local.catalogue_account_roles["read_only_role_arn"],
    local.catalogue_account_roles["ci_role_arn"],

    # Scala lib read Role
    aws_iam_role.s3_scala_releases_read.arn,
  ]
}

module "digitisation_dev_roleset" {
  source = "../modules/roleset"

  name = "digitisation-dev"

  federated_principal = module.account_federation.principal
  aws_principal       = local.aws_principal

  assumable_role_arns = [
    # Platform
    module.aws_account.read_only_role_arn,

    # Digitisation
    local.digitisation_account_roles["developer_role_arn"],
    local.digitisation_account_roles["read_only_role_arn"],

    # Workflow
    local.workflow_account_roles["read_only_role_arn"],
    local.workflow_account_roles["workflow_support_role_arn"],

    # Storage
    local.storage_account_roles["read_only_role_arn"],

    # Scala lib read Role
    aws_iam_role.s3_scala_releases_read.arn,
  ]
}

module "digitisation_admin_roleset" {
  source = "../modules/roleset"

  name = "digitisation-admin"

  federated_principal = module.account_federation.principal
  aws_principal       = local.aws_principal

  assumable_role_arns = [
    # Platform
    module.aws_account.read_only_role_arn,

    # Digitisation
    local.digitisation_account_roles["admin_role_arn"],
    local.digitisation_account_roles["developer_role_arn"],
    local.digitisation_account_roles["read_only_role_arn"],

    # Workflow
    local.workflow_account_roles["read_only_role_arn"],
    local.workflow_account_roles["workflow_support_role_arn"],

    # Storage
    local.storage_account_roles["read_only_role_arn"],

    # Scala lib read Role
    aws_iam_role.s3_scala_releases_read.arn,
  ]
}

module "digirati_dev_roleset" {
  source = "../modules/roleset"

  name = "digirati-dev"

  federated_principal = module.account_federation.principal
  aws_principal       = local.aws_principal

  assumable_role_arns = [
    # Platform
    module.aws_account.read_only_role_arn,

    # Digirati
    local.digirati_account_roles["admin_role_arn"],
    local.digirati_account_roles["developer_role_arn"],
    local.digirati_account_roles["read_only_role_arn"],
    local.digirati_account_roles["ci_role_arn"],

    # Identity
    local.identity_account_roles["admin_role_arn"],
    local.identity_account_roles["developer_role_arn"],
    local.identity_account_roles["read_only_role_arn"],
    local.identity_account_roles["ci_role_arn"],

    # Identity
    local.experience_account_roles["developer_role_arn"],
    local.experience_account_roles["read_only_role_arn"],
    local.experience_account_roles["ci_role_arn"],

    # Workflow
    local.workflow_account_roles["read_only_role_arn"],

    # Storage
    local.storage_account_roles["read_only_role_arn"]
  ]
}
