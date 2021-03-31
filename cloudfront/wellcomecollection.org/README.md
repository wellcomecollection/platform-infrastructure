# wellcomecollection.org

DNS for the wellcomecollection.org hosted zone. Cloudfront configuration live in another repository: https://github.com/wellcomecollection/wellcomecollection.org/tree/master/cache

## AWS Route53 

If you need access to the Route53 console use [this link](https://console.aws.amazon.com/route53/v2/hostedzones#ListRecordSets/Z0902614YH73JBCZG1MA). You will need to have permissions to assume the role: `arn:aws:iam::267269328833:role/wellcomecollection-assume_role_hosted_zone_update`.