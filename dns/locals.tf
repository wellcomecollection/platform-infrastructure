
locals {
  identity_zone_name_servers = data.terraform_remote_state.identity.outputs.identity_zone_name_servers

  // The outputs from the identity stack contain enough information to construct
  // the whole record (including type, and name) which is useful _but_ we don't
  // want to allow the outputs from that stack to set those details here in order
  // to more tightly control of wellcomecollection.org records in this stack.
  identity_ses_txt_records = data.terraform_remote_state.identity.outputs.wellcomecollection_org_ses_vertification_token[["records"]]
  identity_dkim_cname = data.terraform_remote_state.identity.outputs.wellcomecollection_org_ses_dkim_tokens
  identity_ses_dkim_records = toset([
    for record in local.identity_dkim_cname : split(".", record["name"])[0]
  ])
}
