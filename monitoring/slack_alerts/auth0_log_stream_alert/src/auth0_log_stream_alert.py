"""
This is a Lambda which receives events from the Auth0 log stream rule in https://github.com/wellcomecollection/identity/blob/main/infra/scoped/auth0-logs.tf

They look like:

{
  "environment": string,
  "tenant_name": string
  "log_id": string,
}

It sends alerts to Slack which link back to the log event in Auth0.

"""

import functools
import json
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


def get_short_message(event):
    env = event["environment"]
    return f"Error from Auth0 ({env})"


def get_message_block(event):
    env = event["environment"]
    log_id = event["log_id"]
    tenant_name = event["tenant_name"]
    log_url = f"https://manage.auth0.com/dashboard/eu/{tenant_name}/logs/{log_id}?page=1"
    message_text = '\n'.join([
        f"**Error from Auth0 ({env})**",
        f":pager: [View error in Auth0 dashboard]({log_url})"
    ])
    return {
        "type": "section",
        "text": {
            "type": "mrkdwn",
            "text": message_text
        }
    }


@log_on_error
def main(event, _ctxt=None):
    if not should_alert_for_event(event):
        return

    webhook_url = get_secret_string(secret_id="monitoring/critical_slack_webhook")
    slack_payload = {
        "username": "auth0-log-stream-alerts",
        "icon_emoji": ":rotating_light:",
        "text": get_short_message(event),
        "blocks": [
            {
                "color": "danger"
            }
        ]
    }

    print(f"Sending message {json.dumps(slack_payload)}")

    req = urllib.request.Request(
        webhook_url,
        data=json.dumps(slack_payload).encode("utf8"),
        headers={"Content-Type": "application/json"}
    )
    resp = urllib.request.urlopen(req)
    assert resp.status == 200, resp
