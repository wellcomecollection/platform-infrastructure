locals {
  subdomain_modifier = var.environment == "prod" ? "" : "-${var.environment}"

  distro_alias = "iiif${local.subdomain_modifier}.wellcomecollection.org"

  dds_domain   = "dds${local.subdomain_modifier}.dlcs.io"
  iiif_domain  = "iiif${local.subdomain_modifier}.dlcs.io"
  loris_domain = "iiif-origin.wellcomecollection.org"
  dlcs_domain  = "dlcs.io"
}

resource "aws_cloudfront_distribution" "iiif" {
  aliases = [
    local.distro_alias
  ]

  origin {
    domain_name = local.dds_domain
    origin_id   = "dds"

    custom_origin_config {
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]

      http_port = 80
      https_port = 443
    }
  }

  origin {
    domain_name = local.dlcs_domain
    origin_id   = "dlcs"

    custom_origin_config {
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]

      http_port = 80
      https_port = 443
    }
  }

  origin {
    domain_name = local.loris_domain
    origin_id   = "loris"

    custom_origin_config {
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols = [
        "TLSv1.2",
      ]

      http_port = 80
      https_port = 443
    }
  }

  origin {
    domain_name = local.iiif_domain
    origin_id   = "iiif"

    custom_origin_config {
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]

      http_port = 80
      https_port = 443
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "IIIF APIs (${var.environment})"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "dlcs"

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

  ordered_cache_behavior {
    path_pattern     = "image/V00*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "loris"

    forwarded_values {
      query_string = true
      headers = []

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 604800
    default_ttl            = 86400
    max_ttl                = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "image/L00*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "loris"

    forwarded_values {
      query_string = true
      headers = []

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 604800
    default_ttl            = 86400
    max_ttl                = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "image/M00*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "loris"

    forwarded_values {
      query_string = true
      headers = []

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 604800
    default_ttl            = 86400
    max_ttl                = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "image/B00*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "loris"

    forwarded_values {
      query_string = true
      headers = []

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 604800
    default_ttl            = 86400
    max_ttl                = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "image/N00*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "loris"

    forwarded_values {
      query_string = true
      headers = []

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 604800
    default_ttl            = 86400
    max_ttl                = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "image/A00*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "loris"

    forwarded_values {
      query_string = true
      headers = []

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 604800
    default_ttl            = 86400
    max_ttl                = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "image/W00*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "loris"

    forwarded_values {
      query_string = true
      headers = []

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 604800
    default_ttl            = 86400
    max_ttl                = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "image/S00*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "loris"

    forwarded_values {
      query_string = true
      headers = []

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 604800
    default_ttl            = 86400
    max_ttl                = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "thumbs/*.*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "dlcs"

    forwarded_values {
      query_string = true
      headers = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "thumbs/b*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "iiif"

    forwarded_values {
      query_string = true
      headers = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "image/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "dlcs"

    forwarded_values {
      query_string = true
      headers = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "av/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "dlcs"

    forwarded_values {
      query_string = true
      headers = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "pdf/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "dlcs"

    forwarded_values {
      query_string = true
      headers = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "dash/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "dds"

    forwarded_values {
      query_string = true
      headers = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "text/v1*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "iiif"

    forwarded_values {
      query_string = true
      headers = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  tags = {
    Managed = "terraform"
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