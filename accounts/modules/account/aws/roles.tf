module "cloudhealth" {
  source = "../../roles/cloudhealth"
}

module "qualys" {
  source = "../../roles/qualys"
}

module "threataware" {
  source = "../../roles/threataware"
}
