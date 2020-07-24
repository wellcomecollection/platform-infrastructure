locals {
  subdomain_modifier = var.environment == "prod" ? "" : "-${var.environment}"

  distro_alias = "api${local.subdomain_modifier}.wellcomecollection.org"

  catalogue_domain = "catalogue.api${local.subdomain_modifier}.wellcomecollection.org"
  stacks_domain    = "stacks.api${local.subdomain_modifier}.wellcomecollection.org"
  storage_domain   = "storage.api${local.subdomain_modifier}.wellcomecollection.org"
  root_s3_domain   = "wellcomecollection-public-api.s3.amazonaws.com"
}

resource "aws_cloudfront_distribution" "wellcomecollection" {
  aliases = [
    local.distro_alias
  ]

  origin {
    domain_name = local.catalogue_domain
    origin_id   = "catalogue_api"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }

  origin {
    domain_name = local.stacks_domain
    origin_id   = "stacks_api"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }

  origin {
    domain_name = local.storage_domain
    origin_id   = "storage_api"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }

  origin {
    domain_name = local.root_s3_domain
    origin_id   = "root"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Collection APIs (${var.environment})"

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
    path_pattern     = "/catalogue/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "catalogue_api"

    forwarded_values {
      query_string = true
      headers = ["Authorization"]

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/storage/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "storage_api"

    forwarded_values {
      query_string = true
      headers = ["Authorization"]

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    viewer_protocol_policy = "https-only"
  }

  ordered_cache_behavior {
    path_pattern     = "/stacks/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "stacks_api"

    forwarded_values {
      query_string = true
      headers = ["Authorization"]

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    viewer_protocol_policy = "https-only"
  }

  price_class = "PriceClass_100"
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
    ssl_support_method = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
