# CloudFront Invalidation

Lambda function for invalidating CloudFront caches, triggered by SNS topic. 

SNS message body is an array of paths to invalidate, e.g. 
```
{ "paths": ["/path/to/invalidate", "/wildcard/path*", "/catalogue/v2/works/z869w74a"] }
```

SNS timestamp, ie. the time (GMT) when the notification was published, is used for [`CallerReference`](https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_CreateInvalidation.html#API_CreateInvalidation_RequestSyntax) parameter to `CreateInvalidationCommand`.
