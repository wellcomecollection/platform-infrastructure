locals {  
  account_ids_map = {
    "catalogue"    = "756629837203"
    "platform"     = "760097843905"
    "storage"      = "975596993436"
    "workflow"     = "299497370133"
    "experience"   = "130871440101"
    "digirati"     = "653428163053"
    "identity"     = "770700576653"
    "data_science" = "964279923020"
  }

  # list of accoubnt ids from the above map
  account_ids = values(local.account_ids_map)

  namespace = "uk.ac.wellcome"
}