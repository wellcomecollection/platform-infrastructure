resource "aws_s3_bucket" "redirect" {
  bucket = var.from
  acl    = "private"

  website {
    redirect_all_requests_to = var.to
  }

  tags = {
    Description = "Website used for redirecting ${var.from} to ${var.to}"
  }
}

data "template_file" "readme" {
  template = file("${path.module}/bucket-README.tpl")
  vars = {
    from_url = var.from
    to_url   = var.to
  }
}

resource "aws_s3_bucket_object" "readme" {
  bucket = aws_s3_bucket.redirect.bucket
  key    = "README.md"

  content = data.template_file.readme.rendered
}

resource "aws_route53_record" "redirect_domain" {
  name    = var.from
  zone_id = var.zone_id
  type    = "A"

  alias {
    name                   = aws_s3_bucket.redirect.website_domain
    zone_id                = aws_s3_bucket.redirect.hosted_zone_id
    evaluate_target_health = true
  }

  provider = aws.dns
}
