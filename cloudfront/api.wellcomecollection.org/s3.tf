// S3 origin for redirect to developers.wellcomecollection.org
resource "aws_s3_bucket" "public_api" {
  bucket = "wellcomecollection-public-api"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjects",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::wellcomecollection-public-api/*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket_object" "object" {
  bucket       = aws_s3_bucket.public_api.bucket
  key          = "index.html"
  source       = "${path.module}/s3_objects/index.html"
  etag         = md5(file("${path.module}/s3_objects/index.html"))
  content_type = "text/html"
}