locals {
  root_s3_domain = "wellcomecollection-public-api.s3.amazonaws.com"
}

resource "aws_cloudfront_distribution" "wellcomecollection" {
  aliases = var.aliases

  origin {
    domain_name = var.origin_domains.catalogue
    origin_id   = "catalogue_api_delta"
    origin_path = "" // https://github.com/hashicorp/terraform-provider-aws/issues/12065#issuecomment-587518720

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"] // API Gateway V2 requires TLSv1.2
    }
  }

  // TODO remove this origin once the new one is active
  origin {
    domain_name = var.origin_domains.catalogue_old
    origin_id   = "catalogue_api"
    origin_path = "" // https://github.com/hashicorp/terraform-provider-aws/issues/12065#issuecomment-587518720

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }

  origin {
    domain_name = var.origin_domains.stacks
    origin_id   = "stacks_api"
    origin_path = "" // https://github.com/hashicorp/terraform-provider-aws/issues/12065#issuecomment-587518720

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }

  origin {
    domain_name = var.origin_domains.storage
    origin_id   = "storage_api"
    origin_path = "" // https://github.com/hashicorp/terraform-provider-aws/issues/12065#issuecomment-587518720

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }

  origin {
    domain_name = local.root_s3_domain
    origin_id   = "root"
    origin_path = "" // https://github.com/hashicorp/terraform-provider-aws/issues/12065#issuecomment-587518720
  }

  origin {
    domain_name = var.origin_domains.text
    origin_id   = "text_api"
    origin_path = "" // https://github.com/hashicorp/terraform-provider-aws/issues/12065#issuecomment-587518720

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = var.comment

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "root"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern    = "/catalogue/*"
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]
    // TODO: switch this over _after_ adding the new origin (this is already done in staging)
    // target_origin_id = "catalogue_api_delta"
    target_origin_id = "catalogue_api"

    forwarded_values {
      query_string = true
      headers      = ["Authorization"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/storage/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "storage_api"

    forwarded_values {
      query_string = true
      headers      = ["Authorization"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0

    viewer_protocol_policy = "https-only"
  }

  ordered_cache_behavior {
    path_pattern     = "/stacks/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "stacks_api"

    forwarded_values {
      query_string = true
      headers      = ["Authorization"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0

    viewer_protocol_policy = "https-only"
  }

  ordered_cache_behavior {
    path_pattern     = "/text/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "text_api"

    forwarded_values {
      query_string = true
      headers      = []

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 24 * 60 * 60
    max_ttl     = 365 * 24 * 60 * 60

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class         = "PriceClass_100"
  default_root_object = "index.html"

  tags = {
    Managed = "terraform"
  }

  logging_config {
    bucket          = "weco-cloudfront-logs.s3.amazonaws.com"
    include_cookies = false
    prefix          = "api_root"
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
