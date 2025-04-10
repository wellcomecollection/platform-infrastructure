locals {

  // Rate limiting based on https://github.com/wellcomecollection/wellcomecollection.org/blob/main/cache/modules/wc_org_cloudfront/waf.tf
  // Rate-limits cover 5 minute window  
  blanket_rate_limit = 2500

  restrictive_rate_limit  = 1000
  restricted_path_regexes = ["^\\/presentation\\/collections$"]

  lenient_rate_limit   = 10000
  lenient_path_regexes = ["^\\/image$", "^\\/thumbs$"]

  // This is the complete list of Bot Control rules from
  // https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-bot.html
  //
  // For ease of maintenance, we have the complete list here and comment out those rules which are
  // we wish to be enabled or that we wish to remain enabled.
  // Everything that is not commented out in this list will be disabled by setting its action to count.
  //
  // Config and rationale currently reflect's @jamieparkinson's understanding 3/1/2024
  //
  // TL;DR comment out a rule if you want to enable it
  bot_control_rule_no_block_list = [
    "CategoryAdvertising",       // No substantial traffic
    "CategoryArchiver",          // Traffic is always desirable
    "CategoryContentFetcher",    // Traffic is always desirable
    "CategoryEmailClient",       // Traffic is always desirable
    "CategoryHttpLibrary",       // High-risk for breaking scripts and other application services
    "CategoryLinkChecker",       // No substantial traffic
    "CategoryMiscellaneous",     // No substantial traffic
    "CategoryMonitoring",        // Traffic is always desirable
    "CategoryScrapingFramework", // No substantial traffic
    "CategorySearchEngine",      // Traffic is always desirable
    "CategorySecurity",          // Traffic is always desirable
    // "CategorySeo",            // Unverified SEO bots are the source of the _vast_ majority of our bot traffic
    "CategorySocialMedia",       // Traffic is always desirable
    "CategoryAI",                // No substantial traffic
    "SignalAutomatedBrowser",    // No substantial traffic
    "SignalKnownBotDataCenter",  // Known bot data centres include "good" bots such as Updown
    "SignalNonBrowserUserAgent", // High risk for breaking scripts and other application services
    // These are for targeted Bot Control, which we don't use
    // "TGT_VolumetricIpTokenAbsent",
    // "TGT_VolumetricSession",
    // "TGT_SignalAutomatedBrowser",
    // "TGT_SignalBrowserInconsistency",
    // "TGT_TokenReuseIp",
    // "TGT_ML_CoordinatedActivityMedium and TGT_ML_CoordinatedActivityHigh"
  ]
}

resource "aws_wafv2_web_acl" "acl" {
  name        = "${var.namespace}-cloudfront-acl-${var.stage}"
  description = "Access control for the iiif.wellcomecollection.org CloudFront distributions"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "managed-ip-blocking"
    priority = 0

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        // https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-ip-rep.html
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${var.namespace}-cloudfront-acl-ip-block-${var.stage}"
    }
  }

  // RATE LIMITING
  rule {
    name     = "geo-rate-limit-APAC"
    priority = 3

    action {
      count { }
    }

    statement {
      rate_based_statement {
        aggregate_key_type    = "CONSTANT"
        evaluation_window_sec = 60
        limit                 = 500

        scope_down_statement {
          geo_match_statement {
            // We have seen significant bot traffic from these regions,
            // so we rate limit to a lower threshold.
            country_codes = [
              "CN",
              "SG",
              "HK",
            ]
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.namespace}-geo-rate-limit-apac-${var.stage}"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "geo-rate-limit-LATAM"
    priority = 4

    action {
      count {}
    }

    statement {
      rate_based_statement {
        aggregate_key_type    = "CONSTANT"
        evaluation_window_sec = 60
        limit                 = 200

        scope_down_statement {
          geo_match_statement {
            // We have seen significant bot traffic from these regions,
            // so we rate limit to a lower threshold.
            country_codes = [
              "BR",
            ]
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.namespace}-geo-rate-limit-latam-${var.stage}"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "blanket-rate-limiting"
    priority = 5

    action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = local.blanket_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${var.namespace}-weco-cloudfront-acl-rate-limit-${var.stage}"
    }
  }

  rule {
    name     = "restrictive-rate-limiting"
    priority = 6

    action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = local.restrictive_rate_limit
        aggregate_key_type = "IP"

        scope_down_statement {
          regex_pattern_set_reference_statement {
            field_to_match {
              uri_path {}
            }

            arn = aws_wafv2_regex_pattern_set.restricted_urls.arn

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${var.namespace}-weco-cloudfront-restrictive-rate-limit-${var.stage}"
    }
  }

  rule {
    name     = "lenient-rate-limiting"
    priority = 7

    action {
      count {}
    }

    statement {
      rate_based_statement {
        limit              = local.lenient_rate_limit
        aggregate_key_type = "IP"

        scope_down_statement {
          regex_pattern_set_reference_statement {
            field_to_match {
              uri_path {}
            }

            arn = aws_wafv2_regex_pattern_set.lenient_urls.arn

            text_transformation {
              priority = 1
              type     = "URL_DECODE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${var.namespace}-weco-cloudfront-lenient-rate-limit-${var.stage}"
    }
  }

  // See: https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-baseline.html#aws-managed-rule-groups-baseline-crs
  rule {
    name     = "core-rule-group"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          // Overriding this rule as it causes failure in our e2e tests where "localhost" appears in the request
          // Specifically running item requesting tests locally, where the URL path /auth/token?messageId=1&origin=http://localhost
          // This rule is probably trying to stop the exfiltration of EC2 metadata from the localhost endpoint on an instance.
          name = "EC2MetaDataSSRF_QUERYARGUMENTS"

          action_to_use {
            allow {}
          }
        }

        rule_action_override {
          // Overriding this rule as it the IIIF dashboard sometimes requires POSTing a request
          // with a large body, which is blocked by this rule.
          name = "SizeRestrictions_BODY"

          action_to_use {
            allow {}
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${var.namespace}-cloudfront-acl-core-${var.stage}"
    }
  }

  // See: https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-use-case.html#aws-managed-rule-groups-use-case-sql-db
  rule {
    name     = "sqli-rule-group"
    priority = 11

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${var.namespace}-cloudfront-acl-sqli-${var.stage}"
    }
  }

  // See: https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-baseline.html#aws-managed-rule-groups-baseline-known-bad-inputs
  rule {
    name     = "known-bad-inputs-rule-group"
    priority = 12

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${var.namespace}-cloudfront-acl-known-bad-inputs-${var.stage}"
    }
  }

  rule {
    name     = "bot-control-rule-group"
    priority = 13

    // Because the Bot Control rules are quite aggressive, they block some useful bots
    // such as Updown. While we could add overrides for specific bots, we don"t want to have to
    // keep coming back here as we use different monitoring services, scripts, etc.
    //
    // Instead, we"re starting by disabling most of the more high-risk rules and retaining only the
    // ones like CategorySeo which we know cover the majority of our known-bad bot traffic.
    // Rules can be found here:
    // https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-bot.html
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesBotControlRuleSet"
        vendor_name = "AWS"

        managed_rule_group_configs {
          aws_managed_rules_bot_control_rule_set {
            inspection_level = "COMMON"
          }
        }

        dynamic "rule_action_override" {
          for_each = local.bot_control_rule_no_block_list
          content {
            name = rule_action_override.value
            action_to_use {
              count {}
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "${var.namespace}-cloudfront-acl-bot-control-${var.stage}"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = "${var.namespace}-cloudfront-acl-metric-${var.stage}"
  }
}

resource "aws_wafv2_regex_pattern_set" "restricted_urls" {
  name  = "${var.namespace}-restricted-urls-${var.stage}"
  scope = "CLOUDFRONT"

  dynamic "regular_expression" {
    for_each = local.restricted_path_regexes
    content {
      regex_string = regular_expression.value
    }
  }
}

resource "aws_wafv2_regex_pattern_set" "lenient_urls" {
  name  = "${var.namespace}-lenient-urls-${var.stage}"
  scope = "CLOUDFRONT"

  dynamic "regular_expression" {
    for_each = local.lenient_path_regexes
    content {
      regex_string = regular_expression.value
    }
  }
}
