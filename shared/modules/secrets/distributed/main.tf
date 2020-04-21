module "secrets" {
  source = "../secret"

  key_value_map = local.name_value_map
}