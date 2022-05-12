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
import re
import urllib.request
from urllib.error import HTTPError

import boto3


def log_on_error(fn):
    @functools.wraps(fn)
    def wrapper(*args, **kwargs):
        try:
            return fn(*args, **kwargs)
        except Exception:
            print(redact_string(f"args   = {args!r}"), file=sys.stderr)
            print(redact_string(f"kwargs = {kwargs!r}"), file=sys.stderr)
            raise

    return wrapper


def redact_string(string):
    """
    Removes email addresses and user IDs from strings.
    We have no reason to believe they'll appear in logs, but this is a defensive
    way of removing them
    """
    email_address_regex = r"[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+"
    user_id_regex = r"(auth0\|)?p?[0-9]{7}"

    string = re.sub(email_address_regex, "<email redacted>", string)
    string = re.sub(user_id_regex, "<user id redacted>", string)
    return string


def get_secret_string(*, secret_id):
    """
    Look up the value of a SecretString in Secrets Manager.
    """
    secrets_client = boto3.client("secretsmanager")

    return secrets_client.get_secret_value(SecretId=secret_id)["SecretString"]


def should_alert_for_event(log_event):
    """
    Should we send a Slack alert for this event type?
    Listed here: https://auth0.com/docs/deploy-monitor/logs/log-event-type-codes
    """
    # These keys should match those set in the event transform rule
    # https://github.com/wellcomecollection/identity/blob/main/infra/scoped/auth0-logs.tf#L55
    event_type = log_event["log_event_type"]
    description = log_event["log_description"]

    no_alert_prefixes = [
        "s",  # Success
        "w", # Warnings during login
        "limit",  # IP address blocking etc
        "sys",  # Auth0 system events
        "gd",  # Stuff related to MFA
    ]
    no_alert_codes = [
        "admin_update_launch",  # Auth0 Update Launched
        "cls",  # Code/Link Sent
        "cs",  # Code Sent
        "du",  # Deleted User
        "fcpr",  # Failed change password request (account doesn't exist)
        "fp",  # Incorrect password
        "mfar",  # MFA required
        "mgmt_api_read",  # Management API read operation
        "pla",  # Pre-login assessment
        "pwd_leak",  # A leaked passwork was used
        "resource_cleanup",  # Refresh token excess warning
        "ublkdu",  # User block released
        "fertft",  # Unknown or invalid refresh token
    ]
    no_alert_generic_failure_description_substrings = [
        "You may have pressed the back button",
        "PIN is not valid : PIN is trivial",
    ]

    if any(event_type.startswith(prefix) for prefix in no_alert_prefixes):
        return False

    if event_type in no_alert_codes:
        return False

    if event_type == "f" and any(
        substring in description
        for substring in no_alert_generic_failure_description_substrings
    ):
        return False

    return True


def get_log_url(log_id, *, tenant_name):
    return f"https://manage.auth0.com/dashboard/eu/{tenant_name}/logs/{log_id}?page=1"


@log_on_error
def main(event, _ctxt=None):
    webhook_url = get_secret_string(secret_id="monitoring/critical_slack_webhook")
    # There will only ever be 1 record
    log_event = json.loads(event["Records"][0]["Sns"]["Message"])

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
                    "text": "\n".join([short_message, message_content]),
                },
            }
        ],
    }

    req = urllib.request.Request(
        webhook_url,
        data=json.dumps(slack_payload).encode("utf8"),
        headers={"Content-Type": "application/json"},
    )

    try:
        urllib.request.urlopen(req)
    except HTTPError as err:
        raise Exception(redact_string(f"{err} - {err.read()}"))
