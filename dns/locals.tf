
locals {
  identity_zone_name_servers = data.terraform_remote_state.identity.outputs.identity_zone_name_servers
}
