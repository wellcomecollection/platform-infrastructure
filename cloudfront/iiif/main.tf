locals {
  subdomain_modifier = var.environment == "prod" ? "" : "-${var.environment}"

  distro_alias = "iiif-${var.environment}.wellcomecollection.org"

  dds_domain   = "dds${local.subdomain_modifier}.dlcs.io"
  iiif_domain  = "iiif${local.subdomain_modifier}.dlcs.io"
  loris_domain = "iiif-origin.wellcomecollection.org"
  dlcs_domain  = "dlcs.io"

  origins = [
    {
      domain_name = local.dds_domain
      origin_id   = "dds"
    },
    {
      domain_name = local.dlcs_domain
      origin_id   = "dlcs"
    },
    {
      domain_name = local.loris_domain
      origin_id   = "loris"
    },
    {
      domain_name = local.iiif_domain
      origin_id   = "iiif"
    }
  ]

  ordered_cache_behaviors = [
    {
      path_pattern     = "image/V00*"
      target_origin_id = "loris"
    },
    {
      path_pattern     = "image/L00*"
      target_origin_id = "loris"
    },
    {
      path_pattern     = "image/M00*"
      target_origin_id = "loris"
    },
    {
      path_pattern     = "image/B00*"
      target_origin_id = "loris"
    },
    {
      path_pattern     = "image/N00*"
      target_origin_id = "loris"
    },
    {
      path_pattern     = "image/A00*"
      target_origin_id = "loris"
    },
    {
      path_pattern     = "image/W00*"
      target_origin_id = "loris"
    },
    {
      path_pattern     = "image/S00*"
      target_origin_id = "loris"
    },
    {
      path_pattern     = "thumbs/*.*"
      target_origin_id = "dlcs"
    },
    {
      path_pattern     = "thumbs/b*"
      target_origin_id = "iiif"
    },
    {
      path_pattern     = "image/*"
      target_origin_id = "dlcs"
    },
    {
      path_pattern     = "av/*"
      target_origin_id = "dlcs"
    },
    {
      path_pattern     = "pdf/*"
      target_origin_id = "dlcs"
    },
    {
      path_pattern     = "dash/*"
      target_origin_id = "dds"
    },
    {
      path_pattern     = "text/v1*"
      target_origin_id = "iiif"
    },
  ]
}

resource "aws_cloudfront_distribution" "iiif" {
  aliases = [
    local.distro_alias
  ]

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

  dynamic "origin" {
    for_each = local.origins

    content {
      domain_name = origin.value["domain_name"]
      origin_id   = origin.value["origin_id"]

      custom_origin_config {
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols   = ["TLSv1"]

        http_port  = 80
        https_port = 443
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = local.ordered_cache_behaviors

    content {
      path_pattern    = ordered_cache_behavior.value["path_pattern"]
      target_origin_id = ordered_cache_behavior.value["target_origin_id"]

      allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods  = ["GET", "HEAD", "OPTIONS"]

      min_ttl                = 0
      default_ttl            = 86400
      max_ttl                = 31536000

      viewer_protocol_policy = "redirect-to-https"

      forwarded_values {
        query_string = true
        headers      = ["*"]

        cookies {
          forward = "all"
        }
      }
    }
  }
}
