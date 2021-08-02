module "secrets" {
  source = "github.com/wellcomecollection/terraform-aws-secrets.git?ref=v1.3.0"

  key_value_map = local.name_value_map
}
