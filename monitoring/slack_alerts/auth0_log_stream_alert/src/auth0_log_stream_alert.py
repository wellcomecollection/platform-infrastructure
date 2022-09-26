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

This Lambda is deployed by running a Terraform plan/apply.

"""

import functools
import json
import sys
import re
import urllib.request
from urllib.error import HTTPError

import boto3


LOG_EVENT_TYPE_CODES = json.load(open("log_event_type_codes.json"))


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
    log_event_type = log_event["log_event_type"]
    log_description = log_event["log_description"]

    # This disables Black until 'fmt: on', which allows us to line up
    # the comments describing the alert codes for readability.
    # fmt: off

    no_alert_code_prefixes = (
        "gd",       # Stuff related to MFA
        "limit",    # IP address blocking etc
        "s",        # Success
        "sys",      # Auth0 system events
    )
    no_alert_codes = {
        "admin_update_launch",  # Auth0 Update Launched
        "cls",                  # Code/Link Sent
        "cs",                   # Code Sent
        "du",                   # Deleted User
        "fcpr",                 # Failed change password request (account doesn't exist)
        "fp",                   # Incorrect password
        "mfar",                 # MFA required
        "mgmt_api_read",        # Management API read operation
        "pla",                  # Pre-login assessment
        "pwd_leak",             # A leaked passwork was used
        "resource_cleanup",     # Refresh token excess warning
        "ublkdu",               # User block released
        "w",                    # Warnings during login
        "fertft",               # Unknown or invalid refresh token
    }

    # fmt: on

    no_alert_descriptions = {
        # f = Failed Login
        "f": [
            "You may have pressed the back button",
            "PIN is not valid : PIN is trivial",
            "Missing required parameter: response type",
            "Unauthorized",
        ],
        # fcp = Failed Change Password
        "fcp": [
            "You may have pressed the back button",
            "PIN is not valid : PIN is trivial",
        ],
        # fs = Failed Signup
        "fs": [
            "Password contains user information",
            "Password is too common",
            "The user already exists.",
            # This is the error we get from Sierra when it rejects
            # somebody's password.
            "PIN is not valid : PIN is trivial",
            # It's not great that Sierra has an upper limit on password
            # length, but it's a known issue and not something we can fix.
            "PIN is not valid : PIN too long",
        ],
        # Rate Limit on the Authentication or Management APIs
        "api_limit": ["Global per second default group limit has been reached"],
    }

    if log_event_type.startswith(no_alert_code_prefixes):
        return False

    if log_event_type in no_alert_codes:
        return False

    for event_code, description_substrings in no_alert_descriptions.items():
        if log_event_type == event_code and any(
            substr in log_description for substr in description_substrings
        ):
            return False

    return True


def should_log_description_for_event(log_event):
    """
    Should the Slack alert for this event include the description?

    We can't include the description in the general case, because it might
    contain PII we don't want in Slack, e.g.

        User jo@example.com failed to log in successfully

    But in certain cases it may be useful to log a description if
    we know it's safe.
    """
    # These keys should match those set in the event transform rule
    # https://github.com/wellcomecollection/identity/blob/main/infra/scoped/auth0-logs.tf#L55
    log_event_type = log_event["log_event_type"]
    log_description = log_event["log_description"]

    # If we're hitting API rate limits, we can log the name of the
    # endpoint that's being limited without giving anything away.
    if log_event_type == "api_limit" and re.match(
        r"You passed the limit of allowed calls to '[^']+'$", log_description
    ):
        return True

    # Here we're matching on the complete text of the description, so we
    # can be confident it doesn't contain PII.
    if log_description in {
        # This is a bit of a weird one that's not a big concern as a one-off,
        # but we'd want to know if it starts happening regularly.
        "Unhandled API response [socket hang up] (cause: [socket hang up]) There was some other error in finding the patron in Sierra",
        "Unhandled API response [socket hang up] (cause: [socket hang up])",
        # I don't know what this means, but it happens somewhat regularly.
        # Passing the description through to Slack may help us spot a pattern,
        # or start a discussion about what's causing it.
        "Missing required parameter: response_type",
    }:
        return True

    return False


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

    # We're deliberately conservative about what we put in this message.
    #
    # Auth0 logs might contain PII, but these messages are sent to
    # a public channel in the Wellcome Slack.  In particular, we can't
    # forward the 'description' field from the event, which may contain
    # user email addresses (e.g. user henry@example.com failed to log in).
    event_type = log_event["log_event_type"]

    try:
        event_description = LOG_EVENT_TYPE_CODES[event_type]
        log_event_description = f"Event type: {event_description}"
    except KeyError:
        log_event_description = f"Unknown event type code: {event_type}"

    log_url = get_log_url(log_event["log_id"], tenant_name=tenant_name)
    link_to_dashboard = f"<{log_url}|View in dashboard>"

    text = " / ".join([log_event_description, link_to_dashboard])

    if should_log_description_for_event(log_event):
        text += "\n> " + log_event["log_description"]

    slack_payload = {
        "username": f"Error from Auth0 ({environment})",
        "icon_emoji": ":rotating_light:" if environment == "prod" else ":warning:",
        "text": event_description,
        "blocks": [{"type": "section", "text": {"type": "mrkdwn", "text": text}}],
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
