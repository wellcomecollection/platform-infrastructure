"""
This is a generic Lambda that can alert on the value of a CloudWatch Metric.

You need to supply three strings as environment variables:

    STR_SINGLE_ERROR_MESSAGE
    = the message to display if there's a single error

    STR_MULTIPLE_ERROR_MESSAGE
    = the message to display if there are multiple errors.  If this includes
      {error_count}, then the actual value will be included in then message

    STR_ALARM_SLUG
    = the slug to display in the name of the Slack message

    STR_ALARM_LEVEL
    = warning or error

"""

import functools
import json
import os
import re
import sys
import urllib.request

import boto3


def log_on_error(fn):
    @functools.wraps(fn)
    def wrapper(*args, **kwargs):
        try:
            return fn(*args, **kwargs)
        except Exception:
            print(f"args   = {args!r}", file=sys.stderr)
            print(f"kwargs = {kwargs!r}", file=sys.stderr)
            raise

    return wrapper


def get_secret_string(*, secret_id):
    """
    Look up the value of a SecretString in Secrets Manager.
    """
    secrets_client = boto3.client("secretsmanager")

    return secrets_client.get_secret_value(SecretId=secret_id)["SecretString"]


def create_message(alarm):
    # This will be a message of the form:
    #
    #     Threshold Crossed: 1 datapoint [2.0 (17/08/21 09:08:00)] was
    #     greater than the threshold (0.0).
    #
    state_reason = alarm["NewStateReason"]
    error_count = int(
        re.search(
            r"\[(?P<count>\d+\.\d+) \(\d{2}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}\)\]", state_reason
        ).group("count")
    )

    if int(error_count) == 1:
        return os.environ["STR_SINGLE_ERROR_MESSAGE"]
    else:
        return os.environ["STR_MULTIPLE_ERROR_MESSAGE"].format(error_count=error_count)


@log_on_error
def main(event, _ctxt=None):
    account = os.environ["ACCOUNT_NAME"]

    alarm = json.loads(event["Records"][0]["Sns"]["Message"])

    webhook_url = get_secret_string(secret_id="monitoring/critical_slack_webhook")

    alarm_name = alarm["AlarmName"]

    if os.environ["STR_ALARM_LEVEL"] == "error":
        icon_emoji = ":rotating_light:"
        color = "danger"
    else:
        icon_emoji = "warning"
        color = "warning"

    slack_payload = {
        "username": f"{account}-{os.environ['STR_ALARM_SLUG']}",
        "icon_emoji": icon_emoji,
        "attachments": [
            {
                "color": color,
                "fallback": alarm_name,
                "title": alarm_name,
                "fields": [{"value": create_message(alarm)}],
            }
        ],
    }

    print("Sending message %s" % json.dumps(slack_payload))

    req = urllib.request.Request(
        webhook_url,
        data=json.dumps(slack_payload).encode("utf8"),
        headers={"Content-Type": "application/json"},
    )
    resp = urllib.request.urlopen(req)
    assert resp.status == 200, resp
