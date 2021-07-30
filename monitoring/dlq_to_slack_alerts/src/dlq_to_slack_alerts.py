"""
Sends a notification to Slack when we see a message on a DLQ.
"""

import httplib
import json
import os

import boto3


def count_messages_on_queue(queue_name):
    sqs_client = boto3.client("sqs")

    queue_url = sqs_client.get_queue_url(QueueName=queue_name)

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


def main(event, _ctxt=None):
    alarm = json.loads(event["Records"][0]["Sns"]["Message"])
    webhook_url = os.environ["SLACK_WEBHOOK"]

    alarm_name = alarm["AlarmName"]

    slack_payload = {
        "username": "cloudwatch-warning",
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

    conn = httplib.HTTPConnection(webhook_url)
    conn.request(
        "POST", "", json.dumps(slack_payload), {"Content-Type": "application/json"}
    )
    conn.getresponse()
