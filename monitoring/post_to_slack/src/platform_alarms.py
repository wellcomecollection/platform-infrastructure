# -*- encoding: utf-8
"""
Platform-specific logic for our Slack alarms.
"""

import re

from cloudwatch_alarms import ThresholdMessage


def simplify_message(message):
    """
    Sometimes a CloudWatch message includes information that we don't want
    to appear in Slack -- e.g. date/time.

    This function tries to strip out extra bits from the message, so we get
    a tight and focused error appearing in Slack.
    """

    # Lambda timeouts have an opaque prefix:
    #
    #     2017-10-12T13:18:31.917Z d1fdfca5-af4f-11e7-a100-030f2a39c6f6 Task
    #     timed out after 10.01 seconds
    #
    # Drop it!
    message = re.sub(
        r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z "
        r"[0-9a-f-]+ (?=Task timed out)",
        "",
        message,
    )

    return message.strip()


def get_human_message(alarm_name, state_reason):
    """
    Sometimes we can provide a more human-readable message than
    "Threshold Crossed".  Try to do so, if possible.
    """
    threshold = ThresholdMessage.from_message(state_reason)

    # For a DLQ, the lower threshold is always going to be zero, so it's
    # enough to state how many items were on the DLQ.  For example:
    #
    #   There is 1 item on the ID minter DLQ.
    #
    if alarm_name.endswith("_dlq_not_empty"):
        queue_name = alarm_name[: -len("_dlq_not_empty")]
        queue_length = threshold.actual_value

        if queue_length == 1:
            message = "There is 1 item"
        else:
            message = f"There are {queue_length} items"

        return message + f" on the {queue_name} DLQ."

    # For unhealthy hosts, the lower threshold is always going to be zero.
    # For example:
    #
    #   There are 2 unhealthy targets in the id_minter ALB target group.
    #
    if alarm_name.endswith("-alb-unhealthy-hosts"):
        group_name = alarm_name[: -len("-alb-unhealthy-hosts")]
        unhealthy_host_count = threshold.actual_value

        if unhealthy_host_count == 1:
            message = "There is 1 unhealthy target"
        else:
            message = f"There are {unhealthy_host_count} unhealthy targets"

        return message + f" in the {group_name} ALB target group."

    # For not-enough-healthy hosts, the lower threshold may be different,
    # so we include that in the message.  For example:
    #
    #   There aren't enough healthy targets in the ingestor
    #   (saw 2, expected at least 3).
    #
    if alarm_name.endswith("-alb-not-enough-healthy-hosts"):
        group_name = alarm_name[: -len("-alb-not-enough-healthy-hosts")]

        if threshold.is_breaching:
            return f"There are no healthy hosts in the {group_name} ALB target group."
        else:
            desired_count = threshold.desired_value
            actual_count = threshold.actual_value

            return (
                f"There aren't enough healthy targets in the {group_name} ALB target group "
                f"(saw {actual_count}, expected at least {desired_count})."
            )

    # Any number of 500 errors is bad!  For example:
    #
    #   There were multiple 500 errors (3) from the ingestor ALB target group.
    #
    # We put the numeral in brackets just to make the sentence easier to read.
    if alarm_name.endswith("-alb-target-500-errors"):
        group_name = alarm_name[: -len("-alb-target-500-errors")]
        error_count = threshold.actual_value

        if error_count == 1:
            return f"There was a 500 error from the {group_name} ALB target group."
        else:
            return f"There were multiple 500 errors ({error_count}) from the {group_name} ALB target group."

    # As are any number of Lambda errors.  Example:
    #
    #   There was an error in the post_to_slack Lambda.
    #
    if alarm_name.startswith("lambda-") and alarm_name.endswith("-errors"):
        lambda_name = alarm_name[len("lambda-") : -len("-errors")]
        error_count = threshold.actual_value

        if error_count == 1:
            return f"There was an error in the {lambda_name} Lambda."
        else:
            return f"There were {error_count} errors in the {lambda_name} Lambda."

    return state_reason
