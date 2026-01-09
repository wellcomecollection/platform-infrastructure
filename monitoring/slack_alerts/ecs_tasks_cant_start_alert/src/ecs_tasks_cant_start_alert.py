"""
This Lambda warns us if any of our ECS services are failing to start
and leaving the event:

    {service} is unable to consistently start tasks successfully.

This helps us spot when, say, we've deployed a bad configuration or we have
an issue with ECS capacity.

== How it works ==

This is the rough architecture:

    +------------------------+
    |   ECS service events   |
    +------------------------+
                |
         all service events
                |
                v
    +-----------------------+
    | CloudWatch Event rule |
    +-----------------------+
                |
   "failed to start" events only"
                |
                v
    +-----------------------+
    |     this Lambda       |
    +-----------------------+
                |
           Slack webhook

The CloudWatch integration is set up in Terraform.

== Example event ==

Here's an example of the sort of event this function receives:

    {
      "account": "760097843905",
      "detail": {
        "clusterArn": "arn:aws:ecs:eu-west-1:760097843905:cluster/catalogue-2023-03-09",
        "createdAt": "2023-04-07T07:22:50.331Z",
        "eventName": "SERVICE_TASK_START_IMPAIRED",
        "eventType": "WARN"
      },
      "detail-type": "ECS Service Action",
      "id": "b2a64ade-0dfc-adcc-567d-7ffbd225a3c6",
      "region": "eu-west-1",
      "resources": [
        "arn:aws:ecs:eu-west-1:760097843905:service/catalogue-2023-03-09/image_inferrer"
      ],
      "source": "aws.ecs",
      "time": "2023-04-07T07:22:50Z",
      "version": "0"
    }

== Deployment ==

This Lambda is deployed by running a Terraform plan/apply.

"""

import functools
import json
import os
import sys
import urllib.request
from urllib.error import HTTPError
from typing import Any, Callable, Optional

import boto3


SlackSender = Callable[[urllib.request.Request], Any]


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
def main(event, _ctxt=None, *, sender: Optional[SlackSender] = None):
    if sender is None:
        sender = urllib.request.urlopen

    sess = boto3.Session()

    account = os.environ["ACCOUNT_NAME"]
    aws_region = os.environ["AWS_REGION"]

    webhook_url = get_secret_string(sess, secret_id="monitoring/critical_slack_webhook")

    # The 'resources' list will contain a list of ECS service ARNs, e.g.
    #
    #     arn:aws:ecs:eu-west-1:1234567890:service/pipeline/image_inferrer
    #
    # Extract the cluster/service name; in this case 'pipeline' and
    # 'image_inferrer'.
    for r in event["resources"]:
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
                            "value": f"{service_name} is unable to consistently start tasks successfully. <https://{aws_region}.console.aws.amazon.com/ecs/v2/clusters/{cluster_name}/services/{service_name}/deployments?region=eu-west-1|View in console>"
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
            sender(req)
        except HTTPError as err:
            raise Exception(f"{err} - {err.read()}")
