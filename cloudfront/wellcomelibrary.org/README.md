# wellcomelibrary.org

CloudFront distributions & edge-lambdas for managing the redirection of results form the old wellcomelibrary.org site to the new wellcomecollection.org site.

## AWS Route53 

If you need access to the Route53 console use [this link](https://console.aws.amazon.com/route53/v2/hostedzones?#ListRecordSets/Z78J6G8RSOLSZ). You will need to have permissions to assume the role: `arn:aws:iam::267269328833:role/wellcomecollection-assume_role_hosted_zone_update`.

## Deployment
```bash
./deploy
```

