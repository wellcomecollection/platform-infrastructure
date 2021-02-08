module "cert" {
  source = "../modules/certificate"

  domain_name = "roadmap.wellcomecollection.org"

  providers = {
    aws     = aws.us_east_1
    aws.dns = aws.dns
  }
}
