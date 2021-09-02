resource "aws_cloudwatch_event_rule" "costs_report" {
  name                = "costs_report"
  description         = "Starts the costs report lambda"

  # This runs the Lambda at 9am UTC on the second Tuesday of every month.
  # (3#2 = day 3 of the week / Tuesday, 2nd instance of)
  #
  # We run on this day for a few reasons:
  #
  #   - We don't want to run on the 1st of the month because billing data
  #     can take a few days to consolidate.  In particular, some charges
  #     don't appear immediately.  This makes the bill look smaller than it
  #     actually is.  A short delay between the end of the month and running
  #     the billing report means the data should be correct.
  #
  #   - We have planning meetings on Tuesdays, so if this report does turn
  #     up anything worth investigation, we can discuss it at planning.
  #
  schedule_expression = "cron(0 9 ? * 3#2 *)"
}

resource "aws_lambda_permission" "allow_cloudwatch_trigger" {
  action        = "lambda:InvokeFunction"
  function_name = module.costs_report_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.costs_report.arn
}

resource "aws_cloudwatch_event_target" "costs_report" {
  rule = aws_cloudwatch_event_rule.costs_report.id
  arn  = module.costs_report_lambda.arn
}
