module "role" {
  source                          = "../assumable_role/federated"
  name                            = var.name
  federated_principal             = var.federated_principal
  aws_principal                   = var.aws_principal
  max_session_duration_in_seconds = var.max_session_duration_in_seconds
}

module "role_policy" {
  source    = "../role_policies/assume_role"
  role_name = module.role.name

  assumable_roles = var.assumable_role_arns
}
