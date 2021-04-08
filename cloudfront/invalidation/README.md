# CloudFront Invalidation

Lambda function for invalidating CloudFront caches, triggered by SNS topic. 

Message sent to SNS topic is an array of paths to invalidate, e.g. `["/path/to/invalidate", "/wildcard/path*"]`

Current timestamp is used for [`CallerReference`](https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_CreateInvalidation.html#API_CreateInvalidation_RequestSyntax) parameter to `CreateInvalidation`.