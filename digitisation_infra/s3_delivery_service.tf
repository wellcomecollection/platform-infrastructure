resource "aws_s3_bucket" "delivery_service" {
  bucket = "wellcomecollection-delivery-service"

  tags = local.default_tags
}
