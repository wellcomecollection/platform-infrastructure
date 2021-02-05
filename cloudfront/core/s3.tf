resource "aws_s3_bucket" "edge_lambdas" {

  # We have to use the us-east-1 region to create Lambda@Edge functions, so we have
  # the bucket with our Lambda source code in us-east-1 also.
  #
  # See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-how-it-works-tutorial.html#lambda-edge-how-it-works-tutorial-create-function
  provider = aws.us_east_1

  bucket = "wellcomecollection-edge-lambdas"
  acl    = "private"
}
