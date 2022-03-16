"""
This is a Lambda which receives events from the Auth0 log stream rule in https://github.com/wellcomecollection/identity/blob/main/infra/scoped/auth0-logs.tf
These events are passed via an SNS topic to make permissions easier and for consistency with the other alerting lambdas.

The contents of the messages looks like:

{
  "environment": string,
  "tenant_name": string
  "log_id": string,
}

It sends alerts to Slack which link back to the log event in Auth0.

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


def should_alert_for_event(event):
    return True


def get_log_url(log_id, *, tenant_name):
    return f"https://manage.auth0.com/dashboard/eu/{tenant_name}/logs/{log_id}?page=1"


@log_on_error
def main(event, _ctxt=None):
    webhook_url = get_secret_string(secret_id="monitoring/critical_slack_webhook")
    log_event = json.loads(event["Records"][0]["Sns"]["Message"])  # There will only ever be 1 record

    if not should_alert_for_event(log_event):
        return

    environment = log_event["environment"]
    tenant_name = log_event["tenant_name"]

    short_message = f"*Error from Auth0 ({environment})*"
    message_content = f':pager: <{get_log_url(log_event["log_id"], tenant_name=tenant_name)}|View in management dashboard>'

    slack_payload = {
        "username": "auth0-log-stream-alerts",
        "icon_emoji": ":rotating_light:",
        "text": short_message,
        "blocks": [
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": '\n'.join([short_message, message_content])
                }
            }
        ]
    }

    req = urllib.request.Request(
        webhook_url,
        data=json.dumps(slack_payload).encode("utf8"),
        headers={"Content-Type": "application/json"}
    )
    resp = urllib.request.urlopen(req)
    assert resp.status == 200, resp
