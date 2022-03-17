"""
Sends a notification to Slack when we see a message on a DLQ.
"""

import datetime
import functools
import json
import os
import re
import sys
from urllib.parse import quote as urlquote
from urllib.error import HTTPError
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


def build_cloudwatch_url(search_term, log_group_name, start_date, end_date, region):
    """
    Builds a URL that opens the CloudWatch Console with the given filters.
    """
    return (
        f"https://{region}.console.aws.amazon.com/cloudwatch/home"
        f"?region={region}"
        f"#logEventViewer:group={log_group_name};"
        f"filter={urlquote(search_term)};"
        f'start={start_date.strftime("%Y-%m-%dT%H:%M:%SZ")};'
        f'end={end_date.strftime("%Y-%m-%dT%H:%M:%SZ")};'
    )


def datetime_to_cloudwatch_ts(dt):
    """
    Convert a Python ``datetime`` instance to a CloudWatch timestamp,
    the number of milliseconds after Jan 1, 1970 00:00:00 UTC.
    """
    epoch = datetime.datetime(1970, 1, 1, 0, 0, 0)
    return int((dt - epoch).total_seconds()) * 1000


def get_cloudwatch_messages(*, log_group_name, start, end, search_terms):
    """
    Try to find some CloudWatch messages that might be relevant.
    """
    client = boto3.client("logs")

    all_messages = []

    try:
        # CloudWatch wants these parameters specified as seconds since
        # 1 Jan 1970 00:00:00, so convert to that first.
        startTime = datetime_to_cloudwatch_ts(start)
        endTime = datetime_to_cloudwatch_ts(end)

        # We only get the first page of results.  If there's more than
        # one page, we have so many errors that not getting them all
        # in the Slack alarm is the least of our worries!
        for term in search_terms:
            resp = client.filter_log_events(
                logGroupName=log_group_name,
                startTime=startTime,
                endTime=endTime,
                filterPattern=term,
            )

            for e in resp["events"]:
                message = e["message"]
                # Lambda timeouts have an opaque prefix:
                #
                #     2017-10-12T13:18:31.917Z <UUID> Task timed out after 10.01 seconds
                #
                # Drop it!
                message = re.sub(
                    r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z "
                    r"[0-9a-f-]+ (?=Task timed out)",
                    "",
                    message,
                )

                all_messages.append(message)

    except Exception as err:
        print(f"Error in cloudwatch_messages: {err!r}")

    return all_messages


def create_message(alarm, *, function_name):
    # This will be a message of the form:
    #
    #     Threshold Crossed: 1 datapoint [2.0 (17/08/21 09:08:00)] was
    #     greater than the threshold (0.0).
    #
    state_reason = alarm["NewStateReason"]
    error_count = re.search(
        r"\[(?P<count>\d+)\.0 \(\d{2}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}\)\]", state_reason
    ).group("count")

    if int(error_count) == 1:
        return f"There was an error in the {function_name} Lambda"
    else:
        return f"There were {error_count} errors in the {function_name} Lambda"


@log_on_error
def main(event, _ctxt=None):
    account = os.environ["ACCOUNT_NAME"]

    region = boto3.Session().region_name

    alarm = json.loads(event["Records"][0]["Sns"]["Message"])
    webhook_url = get_secret_string(secret_id="monitoring/critical_slack_webhook")

    # The name of our Lambda error alarms should be of the form
    #
    #     lambda-{function_name}-errors
    #
    # e.g. lambda-platform_example_lambda-errors
    #
    alarm_name = alarm["AlarmName"]
    try:
        function_name = re.match(r"^lambda\-(?P<name>.+?)\-errors$", alarm_name).group(
            "name"
        )
    except (AttributeError, IndexError):
        raise Exception(
            f"The Lambda alarm name {alarm_name} does not match the pattern, 'lambda-<function_name>-errors'"
        )

    log_group_name = f"/aws/lambda/{function_name}"

    # Try to get some rough bounds on when this error might have occurred.
    # There's about a 60 second delay on the error and the CloudWatch alarm
    # being triggered.
    state_change_time = datetime.datetime.strptime(
        alarm["StateChangeTime"], "%Y-%m-%dT%H:%M:%S.%f+0000"
    )
    errors_start = state_change_time - datetime.timedelta(minutes=11)
    errors_end = min(
        [datetime.datetime.now(), state_change_time + datetime.timedelta(minutes=9)]
    )

    # Are there any interesting CloudWatch Logs for the Lambda?
    search_terms = ["Traceback", "Task timed out after"]
    cloudwatch_messages = get_cloudwatch_messages(
        log_group_name=log_group_name,
        start=errors_start,
        end=errors_end,
        search_terms=search_terms,
    )

    cloudwatch_urls = [
        build_cloudwatch_url(t, log_group_name, errors_start, errors_end, region)
        for t in search_terms
    ]

    message = create_message(alarm, function_name=function_name)

    slack_payload = {
        "username": f"{account}-lambda-error-alarm",
        "icon_emoji": ":warning:",
        "attachments": [
            {
                "color": "warning",
                "fallback": alarm_name,
                "title": function_name,
                "fields": [{"value": message}],
            }
        ],
    }

    # Add the CloudWatch context to the Slack payload.
    if cloudwatch_messages:
        cloudwatch_message_str = "\n".join(set(cloudwatch_messages))
        slack_payload["attachments"][0]["fields"].append(
            {"title": "CloudWatch messages", "value": cloudwatch_message_str}
        )

    slack_payload["attachments"][0]["fields"].append(
        {"value": " / ".join(cloudwatch_urls)}
    )

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
