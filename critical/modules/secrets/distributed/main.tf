module "secrets" {
  source = "github.com/wellcomecollection/terraform-aws-secrets.git?ref=8bf3759af9e1a19731f28784953dd0a53a2f276f"

  key_value_map = local.name_value_map
}
