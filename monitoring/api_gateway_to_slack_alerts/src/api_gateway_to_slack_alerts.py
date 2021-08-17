"""
Sends a notification to Slack when we see a message on a DLQ.
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


@log_on_error
def main(event, _ctxt=None):
    account = os.environ["ACCOUNT_NAME"]

    alarm = json.loads(event["Records"][0]["Sns"]["Message"])

    # This will be a message of the form:
    #
    #     Threshold Crossed: 1 datapoint [2.0 (17/08/21 09:08:00)] was
    #     greater than the threshold (0.0).
    #
    state_reason = alarm["NewStateReason"]
    error_count = re.search(r'\[(?P<count>\d+)\.0 \(\d{2}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}\)\]', state_reason).group("count")

    print(error_count)

    from pprint import pprint
    pprint(alarm)
    webhook_url = get_secret_string(secret_id="monitoring/critical_slack_webhook")

    alarm_name = alarm["AlarmName"]

    # slack_payload = {
    #     "username": f"{account}-api-gateway-5xx-alarm",
    #     "icon_emoji": ":warning:",
    #     "attachments": [
    #         {
    #             "color": "warning",
    #             "fallback": alarm_name,
    #             "title": alarm_name,
    #             "fields": [{"value": create_message(alarm_name)}],
    #         }
    #     ],
    # }
    #
    # print("Sending message %s" % json.dumps(slack_payload))
    #
    # req = urllib.request.Request(
    #     webhook_url,
    #     data=json.dumps(slack_payload).encode("utf8"),
    #     headers={"Content-Type": "application/json"},
    # )
    # resp = urllib.request.urlopen(req)
    # assert resp.status == 200, resp
