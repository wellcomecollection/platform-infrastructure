"""
Sends a notification to Slack when we see a message on a DLQ.
"""

import functools
import json
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


def count_messages_on_queue(queue_name):
    sqs_client = boto3.client("sqs")

    queue_url = sqs_client.get_queue_url(QueueName=queue_name)["QueueUrl"]

    resp = sqs_client.get_queue_attributes(
        QueueUrl=queue_url, AttributeNames=["ApproximateNumberOfMessages"]
    )

    return int(resp["Attributes"]["ApproximateNumberOfMessages"])


def create_message(alarm_name):
    assert alarm_name.endswith("_dlq_not_empty")
    queue_name = alarm_name[: -len("_dlq_not_empty")]

    queue_length = count_messages_on_queue(f"{queue_name}_dlq")

    if queue_length == 1:
        return f"There is 1 item on the {queue_name} DLQ."
    else:
        return f"There are {queue_length} items on the {queue_name} DLQ."


@log_on_error
def main(event, _ctxt=None):
    alarm = json.loads(event["Records"][0]["Sns"]["Message"])
    webhook_url = get_secret_string(secret_id="monitoring/noncritical_slack_webhook")

    alarm_name = alarm["AlarmName"]

    slack_payload = {
        "username": "sqs-dlq-alarm",
        "icon_emoji": ":warning:",
        "attachments": [
            {
                "color": "warning",
                "fallback": alarm_name,
                "title": alarm_name,
                "fields": [{"value": create_message(alarm_name)}],
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
