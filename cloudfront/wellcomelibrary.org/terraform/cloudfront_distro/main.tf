resource "aws_cloudfront_distribution" "distro" {
  aliases = var.distro_alternative_names

  dynamic "origin" {
    for_each = var.origins
    content {
      origin_id   = origin.value["origin_id"]
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
  comment         = "Wellcome Library (${var.distro_alternative_names[0]})"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.default_target_origin_id

    forwarded_values {
      query_string = true
      headers      = var.default_forwarded_headers

      cookies {
        forward = "all"
      }
    }

    lambda_function_association {
      event_type = var.default_lambda_function_association_event_type
      lambda_arn = var.default_lambda_function_association_lambda_arn
    }

    min_ttl     = null
    default_ttl = null
    max_ttl     = null

    viewer_protocol_policy = var.default_viewer_protocol_policy
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
        headers = concat(
          ordered_cache_behavior.value["headers"],
          var.default_forwarded_headers
        )

        cookies {
          forward = ordered_cache_behavior.value["cookies"]
        }
      }

      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value["lambdas"]
        content {
          event_type = lambda_function_association.value["event_type"]
          lambda_arn = lambda_function_association.value["lambda_arn"]
        }
      }

      min_ttl     = ordered_cache_behavior.value["min_ttl"]
      default_ttl = ordered_cache_behavior.value["default_ttl"]
      max_ttl     = ordered_cache_behavior.value["max_ttl"]

      viewer_protocol_policy = "redirect-to-https"
    }
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