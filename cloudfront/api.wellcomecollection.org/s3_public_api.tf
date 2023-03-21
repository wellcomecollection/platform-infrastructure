// S3 origin for redirect to developers.wellcomecollection.org
resource "aws_s3_bucket" "public_api" {
  bucket = "wellcomecollection-public-api"
}

resource "aws_s3_bucket_acl" "public_api" {
  bucket = aws_s3_bucket.public_api.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "public_api" {
  bucket = aws_s3_bucket.public_api.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_api" {
  bucket = aws_s3_bucket.public_api.id

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

resource "aws_s3_object" "object" {
  bucket       = aws_s3_bucket.public_api.bucket
  key          = "index.html"
  source       = "${path.module}/s3_objects/index.html"
  etag         = md5(file("${path.module}/s3_objects/index.html"))
  content_type = "text/html"
}