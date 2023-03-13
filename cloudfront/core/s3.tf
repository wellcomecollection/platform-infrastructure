resource "aws_s3_bucket" "edge_lambdas" {

  # We have to use the us-east-1 region to create Lambda@Edge functions, so we have
  # the bucket with our Lambda source code in us-east-1 also.
  #
  # See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-how-it-works-tutorial.html#lambda-edge-how-it-works-tutorial-create-function
  provider = aws.us_east_1

  bucket = "wellcomecollection-edge-lambdas"
}

resource "aws_s3_bucket_acl" "edge_lambdas" {
  bucket = aws_s3_bucket.edge_lambdas.id

  provider = aws.us_east_1

  acl = "private"
}

resource "aws_s3_bucket_versioning" "edge_lambdas" {
  bucket = aws_s3_bucket.edge_lambdas.id

  provider = aws.us_east_1

  versioning_configuration {
    status = "Enabled"
  }
}