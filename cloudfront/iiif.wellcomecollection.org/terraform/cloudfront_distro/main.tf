locals {
  subdomain_modifier = var.environment == "prod" ? "" : "-${var.environment}"
  distro_alias       = "iiif${local.subdomain_modifier}.wellcomecollection.org"
}

resource "aws_cloudfront_distribution" "iiif" {
  aliases = [
    local.distro_alias
  ]

  dynamic "origin" {
    for_each = var.origins
    content {
      origin_id   = origin.value["origin_name"]
      domain_name = origin.value["domain_name"]
      origin_path = origin.value["origin_path"]

      custom_origin_config {
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols = [
          "TLSv1",
          "TLSv1.1",
          "TLSv1.2",
        ]

        http_port  = 80
        https_port = 443
      }
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "IIIF APIs (${var.environment})"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "iiif"

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400

    viewer_protocol_policy = "redirect-to-https"
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.behaviours
    content {
      path_pattern     = ordered_cache_behavior.value["path_pattern"]
      allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods   = ["GET", "HEAD", "OPTIONS"]
      target_origin_id = ordered_cache_behavior.value["target_origin_id"]

      forwarded_values {
        query_string = true
        headers      = ordered_cache_behavior.value["headers"]

        cookies {
          forward = "none"
        }
      }

      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value["lambdas"]
        content {
          event_type = lambda_function_association.value["event_type"]
          lambda_arn = lambda_function_association.value["lambda_arn"]
        }
      }

      min_ttl     = 7 * 24 * 60 * 60
      default_ttl = 24 * 60 * 60
      max_ttl     = 365 * 24 * 60 * 60

      viewer_protocol_policy = "redirect-to-https"
    }
  }

  ordered_cache_behavior {
    path_pattern     = "image/s3:*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "loris"

    forwarded_values {
      query_string = true
      headers      = []

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 604800
    default_ttl = 86400
    max_ttl     = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "thumbs/*.*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "dlcs"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "thumbs/b*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "iiif"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "image/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "dlcs"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "av/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "dlcs"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "pdf/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "dlcs"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "dash/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "dds"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "text/v1*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "iiif"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  tags = {
    Managed = "terraform"
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
