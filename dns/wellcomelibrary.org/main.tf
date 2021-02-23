module "stage_wellcomelibrary_org" {
  source = "../modules/ssl_cert"
  hostname = "wellcomelibrary.org"
  subdomain = "stage"

  providers = {
    aws.dns = aws.dns
    aws.cert = aws.us-east-1
  }
}