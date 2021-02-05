resource "aws_s3_bucket" "edge_lambdas" {
  provider = aws.us_east_1

  bucket = "wellcomecollection-edge-lambdas"
  acl    = "private"
}