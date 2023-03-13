resource "aws_s3_bucket" "redirect" {
  bucket = var.from

  tags = {
    Description = "Website used for redirecting ${var.from} to ${var.to}"
  }
}

resource "aws_s3_bucket_acl" "redirect" {
  bucket = var.from
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "redirect" {
  bucket = var.from

  redirect_all_requests_to {
    host_name = var.to
  }
}

resource "aws_s3_object" "readme" {
  bucket = aws_s3_bucket.redirect.bucket
  key    = "README.md"

  content = templatefile(
    "${path.module}/bucket-README.tpl",
    {
      from_url = var.from
      to_url   = var.to
    }
  )
}

resource "aws_route53_record" "redirect_domain" {
  name    = var.from
  zone_id = var.zone_id
  type    = "A"

  alias {
    name    = aws_s3_bucket_website_configuration.redirect.website_domain
    zone_id = aws_s3_bucket.redirect.hosted_zone_id

    evaluate_target_health = true
  }

  provider = aws.dns
}
