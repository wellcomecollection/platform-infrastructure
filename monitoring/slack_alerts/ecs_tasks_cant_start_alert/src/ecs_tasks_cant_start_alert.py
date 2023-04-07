"""
This Lambda warns us if any of our ECS services are failing to start
and leaving the event:

    {service} is unable to consistently start tasks successfully.

This helps us spot when, say, we've deployed a bad configuration or we have
an issue with ECS capacity.

This Lambda is triggered when these events get sent (via a CloudWatch rule),
so we extract the key information and post a message to Slack.

"""

import functools
import json
import os
import sys
import urllib.request
from urllib.error import HTTPError

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


@functools.cache
def get_secret_string(sess, *, secret_id):
    """
    Look up the value of a SecretString in Secrets Manager.
    """
    secrets_client = sess.client("secretsmanager")

    return secrets_client.get_secret_value(SecretId=secret_id)["SecretString"]


@log_on_error
def main(event, _ctxt=None):
    sess = boto3.Session()

    account = os.environ["ACCOUNT_NAME"]

    webhook_url = get_secret_string(sess, secret_id="monitoring/critical_slack_webhook")

    for record in event["Records"]:
        ecs_event = json.loads(record["Sns"]["Message"])

        # The 'resources' list will contain a list of ECS service ARNs, e.g.
        #
        #     arn:aws:ecs:eu-west-1:1234567890:service/pipeline/image_inferrer
        #
        # Extract the cluster/service name; in this case 'pipeline' and
        # 'image_inferrer'.
        for r in ecs_event['resources']:
            _, cluster_name, service_name = r.split("/")

            slack_payload = {
                "username": f"{account}-ecs-tasks-alert",
                "icon_emoji": ":rotating_light:",
                "attachments": [
                    {
                        "color": "danger",
                        "title": f"{cluster_name} / {service_name}",
                        "fields": [
                            {
                                "value": f"{service_name} is unable to consistently start tasks successfully."
                            }
                        ],
                    }
                ],
            }

            print("Sending message %s" % json.dumps(slack_payload))

            req = urllib.request.Request(
                webhook_url,
                data=json.dumps(slack_payload).encode("utf8"),
                headers={"Content-Type": "application/json"},
            )

            try:
                urllib.request.urlopen(req)
            except HTTPError as err:
                raise Exception(f"{err} - {err.read()}")
