module "cert" {
  source = "../../modules/certificate"

  domain_name = "iiif.wellcomecollection.org"

  subject_alternative_names = [
    "iiif-test.wellcomecollection.org",
    "iiif-prod.wellcomecollection.org",
    "iiif-stage.wellcomecollection.org",
  ]

  providers = {
    aws     = aws.us_east_1
    aws.dns = aws.dns
  }
}
