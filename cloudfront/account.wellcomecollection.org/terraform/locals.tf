locals {
  /*account_zone_name_servers = data.terraform_remote_state.identity.outputs.account_zone_name_servers*/
  identity_ses_txt_records = data.terraform_remote_state.identity.outputs.wellcomecollection_org_ses_vertification_token["records"]
  identity_dkim_cname      = data.terraform_remote_state.identity.outputs.wellcomecollection_org_ses_dkim_tokens
  identity_ses_dkim_records = toset([
    for record in local.identity_dkim_cname : split(".", record["name"])[0]
  ])
}