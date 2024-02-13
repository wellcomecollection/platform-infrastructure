locals {
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
  description = "Access control for the wellcomecollection.org CloudFront distributions"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "managed-ip-blocking"
    priority = 0

    override_action {
      count {}
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

  // See: https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-baseline.html#aws-managed-rule-groups-baseline-crs
  rule {
    name     = "core-rule-group"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
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
    priority = 2

    override_action {
      count {}
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
    priority = 3

    override_action {
      count {}
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
    priority = 4

    // Because the Bot Control rules are quite aggressive, they block some useful bots
    // such as Updown. While we could add overrides for specific bots, we don"t want to have to
    // keep coming back here as we use different monitoring services, scripts, etc.
    //
    // Instead, we"re starting by disabling most of the more high-risk rules and retaining only the
    // ones like CategorySeo which we know cover the majority of our known-bad bot traffic.
    // Rules can be found here:
    // https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-bot.html
    override_action {
      count {}
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