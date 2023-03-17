resource "aws_cloudfront_distribution" "wellcomecollection" {
  aliases = var.aliases

  origin {
    domain_name = var.origin_domains.catalogue
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
    domain_name = var.origin_domains.content
    origin_id   = "content_api"
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
    domain_name = var.root_s3_domain
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
    path_pattern     = "/catalogue/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "catalogue_api"

    forwarded_values {
      query_string = true
      headers      = ["Authorization"]

      cookies {
        forward = "all"
      }
    }

    # We don't want to cache these results for too long, because that
    # means we'd be serving stale data -- but nor does this data need to
    # be so fresh that we need to go back to the API every single time.
    #
    # A little bit of caching here should mitigate the effect of somebody
    # sending a flood of requests to /works.
    min_ttl     = 0
    default_ttl = 10
    max_ttl     = 10

    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "content_api"

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    # We don't want to cache these results for too long, because that
    # means we'd be serving stale data -- but nor does this data need to
    # be so fresh that we need to go back to the API every single time.
    #
    # A little bit of caching here should mitigate the effect of somebody
    # sending a flood of requests to /works.
    min_ttl     = 0
    default_ttl = 10
    max_ttl     = 10

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

  tags = var.tags

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
