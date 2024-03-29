locals {
  subdomain_modifier = var.environment == "prod" ? "" : "-${var.environment}"
  distro_alias       = "iiif${local.subdomain_modifier}.wellcomecollection.org"
}

resource "aws_route53_record" "subdomain" {
  name    = local.distro_alias
  records = [aws_cloudfront_distribution.iiif.domain_name]

  zone_id = data.aws_route53_zone.weco_zone.id
  type    = "CNAME"
  ttl     = 300

  provider = aws.dns
}

resource "aws_cloudfront_distribution" "iiif" {
  aliases = [
    local.distro_alias
  ]

  web_acl_id = var.web_acl_id

  dynamic "origin" {
    for_each = var.origins
    content {
      origin_id   = origin.value["origin_id"]
      domain_name = origin.value["domain_name"]
      origin_path = origin.value["origin_path"]

      dynamic "custom_header" {
        for_each = origin.value["forward_host"] ? [
        1] : []
        content {
          name  = "X-Forwarded-Host"
          value = local.distro_alias
        }
      }

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
    target_origin_id = var.default_target_origin_id

    forwarded_values {
      query_string = true
      headers      = ["Origin"]

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

  logging_config {
    include_cookies = false
    bucket          = "${var.logging_bucket}.s3.amazonaws.com"
    prefix          = "${local.distro_alias}/"
  }
}
