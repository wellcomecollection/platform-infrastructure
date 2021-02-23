# ssl_cert

This module creates a ACM certificate, and validates it against a Route53 CNAME record.

You need to provide:

**Variable**
* `hostname` the hostname of for the SSL cert e.g. `wellcomecollection`
* `subdomain` the subdomain of for the SSL cert e.g. `stage`

**Providers**
* `aws.cert` the account in which the certificate will be provisioned. If you're provision a domain name for CloudFront, `region` must be  `us-east-1`
* `aws.dns` the account in which the Route53 configuration lives