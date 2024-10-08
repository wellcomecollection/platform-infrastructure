"""
This is a generic Lambda that can alert on the value of a CloudWatch Metric.

You need to supply these strings as environment variables:

    STR_SINGLE_ERROR_MESSAGE
    = the message to display if there's a single error

    STR_MULTIPLE_ERROR_MESSAGE
    = the message to display if there are multiple errors.  If this includes
      {error_count}, then the actual value will be included in then message

    STR_ALARM_SLUG
    = the slug to display in the name of the Slack message

    STR_ALARM_LEVEL
    = warning or error

Plus optionally:

    CONTEXT_URL_TEMPLATE
    = select the template to use in create_context_url

    INT_SUPERPLURAL_THRESHOLD
    = The number above which this alarm can be considered "very big", triggering a different message and
    causing this alarm to become an error (if it is not already).

    STR_SUPERPLURAL_ERROR_MESSAGE
    = The message to use if the superplural threshold is exceeded.
"""

import datetime
import functools
import json
import os
import re
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


def get_secret_string(*, secret_id):
    """
    Look up the value of a SecretString in Secrets Manager.
    """
    secrets_client = boto3.client("secretsmanager")

    return secrets_client.get_secret_value(SecretId=secret_id)["SecretString"]


def create_context_url(alarm_info):
    # Move the end of the window 3 minutes later as there seems to be
    # a delay in logs propagating to elasticsearch
    to_date = alarm_info["date"] + datetime.timedelta(minutes=3)
    from_date = alarm_info["date"] - datetime.timedelta(minutes=10)
    kibana_to_date = to_date.strftime("%Y-%m-%dT%H:%M:%S.000Z")
    kibana_from_date = from_date.strftime("%Y-%m-%dT%H:%M:%S.000Z")

    # These URL template were obtained by going through the Discover
    # view in Kibana, then copy/pasting the URL and templating a few
    # parameters.
    #
    # They're designed to exclude common operations we don't care about
    # (e.g. 200 OK or 404 Not Found errors) and highlight app errors.
    #
    # Note: if you're replacing or updating these URLs, remember to update
    # the template parameters like to_date/from_date.

    # This is the ID for the index pattern `service-logs-*`
    # You can find index pattern IDs by doing:
    # GET .kibana/_search
    # {
    #   "_source": ["index-pattern.title"],
    #   "query": {
    #     "term": {
    #       "type": "index-pattern"
    #     }
    #   }
    # }
    index_pattern_id = "cb5ba262-ec15-46e3-a4c5-5668d65fe21f"

    if os.environ.get("CONTEXT_URL_TEMPLATE") == "experience-cloudfront-errors":
        url_template = """https://logging.wellcomecollection.org/app/discover#/?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:'{from_date}',to:'{to_date}'))&_a=(columns:!(log),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:'{index_pattern_id}',key:ecs_cluster,negate:!f,params:(query:{cluster_name}),type:phrase),query:(match_phrase:(ecs_cluster:{cluster_name})))),index:'{index_pattern_id}',interval:auto,query:(language:kuery,query:'not%20log:%22*HTTP%2F1.1%5C%22%20200*%22%20and%20not%20log:%22*HTTP%2F1.1%5C%22%20206*%22%20and%20not%20log:%22*HTTP%2F1.1%5C%22%20302*%22%20and%20not%20log:%22*HTTP%2F1.1%5C%22%20304*%22%20and%20not%20log:%22*HTTP%2F1.1%5C%22%20307*%22%20and%20not%20log:%22*HTTP%2F1.1%5C%22%20308*%22%20and%20not%20log:%22*HTTP%2F1.1%5C%22%20400*%22%20and%20not%20log:%22*HTTP%2F1.1%5C%22%20401*%22%20and%20not%20log:%22*HTTP%2F1.1%5C%22%20404*%22%20and%20not%20log:%22*HTTP%2F1.1%5C%22%20410*%22%20and%20not%20log:%22*HTTP%2F1.1%5C%22%20414*%22%20and%20not%20log:%22*HTTP%2F1.1%5C%22%20499*%22%20and%20not%20log:%22*GET%20%2Faccount%2Fapi%2Fusers%2Fme%20401*%22%20and%20not%20log:%22*GET%20%2Faccount%2Fapi%2Fauth%2Fme%20401*%22%20and%20not%20log:%22*%3C--%20GET%20%2Faccount%2Fapi%2Fauth%2Fme*%22%20and%20not%20log:%22*%2Fmanagement%2Fhealthcheck*%22%20and%20not%20log:%22*--%3E%20GET%20%2Faccount%2Fapi%2Fusers%2Fme%2Fitem-requests%20304*%22%20and%20not%20log:%22*-x-%20GET%20%2Faccount%2Fapi%2Fusers%2Fme%2Fitem-requests%20304*%22%20and%20not%20log:%22*--%3E%20GET%20%2Faccount%2Fapi%2Fauth%2Flogin%20302*%22%20and%20not%20log:%22-x-%3E%20GET%20%2Faccount%2Fapi%2Fauth%2Flogin%20302*%22%20and%20not%20log:%22*--%3E%20GET%20%2Faccount*%20200*%22%20and%20not%20log:%22*-x-%3E%20GET%20%2Faccount*%20200*%22%20and%20not%20log:%22%3C--%20GET%20%2Faccount%2Fapi%2Fusers%2Fme%2Fitem-requests%22%20and%20not%20log:%22%3C--%20GET%20%2Faccount%2Fapi%2Fauth%2Flogin%22'),sort:!(!('@timestamp',desc)))"""

        if alarm_info["name"] == "cloudfront_wc.org_error_5xx":
            cluster_name = "experience-frontend-prod"
        elif alarm_info["name"] == "cloudfront_stage.wc.org_error_5xx":
            cluster_name = "experience-frontend-stage"
        else:
            return

        return {
            "url": url_template.format(
                cluster_name=cluster_name,
                to_date=kibana_to_date,
                from_date=kibana_from_date,
                index_pattern_id=index_pattern_id,
            ),
            "label": "View logs in Kibana",
        }

    if os.environ.get("CONTEXT_URL_TEMPLATE") == "identity-api-gateway-5xx-errors":
        url_template = """https://logging.wellcomecollection.org/app/discover#/?_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:'{from_date}',to:'{to_date}'))&_a=(columns:!(log),filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:'{index_pattern_id}',key:ecs_cluster,negate:!f,params:(query:{cluster_name}),type:phrase),query:(match_phrase:(ecs_cluster:{cluster_name})))),index:'{index_pattern_id}',interval:auto,query:(language:kuery,query:'not%20log:%22*HTTP%20200%20OK*%22%20and%20not%20log:%22*GET%20%2Fusers%2Fme%2Fitem-requests%20HTTP%2F1.1%5C%22%20200*%22'),sort:!(!('@timestamp',desc)))"""
        if alarm_info["name"] == "identity-api-prod-5xx-alarm":
            cluster_name = "identity-prod"
        elif alarm_info["name"] == "identity-api-stage-5xx-alarm":
            cluster_name = "identity-stage"
        else:
            return

        return {
            "url": url_template.format(
                cluster_name=cluster_name,
                to_date=kibana_to_date,
                from_date=kibana_from_date,
                index_pattern_id=index_pattern_id,
            ),
            "label": "View logs in Kibana",
        }


def get_alarm_info(alarm):
    # This will be a message of the form:
    #
    #     Threshold Crossed: 1 datapoint [2.0 (17/08/21 09:08:00)] was
    #     greater than the threshold (0.0).
    #
    m = re.search(
        r"\[(?P<count>\d+\.\d+) \((?P<date>\d{2}/\d{2}/\d{2} \d{2}:\d{2}:\d{2})\)\]",
        alarm["NewStateReason"],
    )

    if m is None:
        return

    return {
        "name": alarm["AlarmName"],
        "count": float(m.group("count")),
        "date": datetime.datetime.strptime(m.group("date"), "%d/%m/%y %H:%M:%S"),
    }


def create_message(alarm_info):
    lines = []

    if int(alarm_info["count"]) == 1:
        lines.append(os.environ["STR_SINGLE_ERROR_MESSAGE"])
    else:
        if int(alarm_info["count"]) == alarm_info["count"]:
            error_count = int(alarm_info["count"])
        else:
            error_count = alarm_info["count"]

        error_template = os.environ[
            "STR_SUPERPLURAL_ERROR_MESSAGE"
            if is_alarm_count_very_big(error_count, os.environ)
            else "STR_MULTIPLE_ERROR_MESSAGE"
        ]

        lines.append(error_template.format(error_count=error_count))

    context_url = create_context_url(alarm_info)
    if context_url is not None:
        lines.append(f"👉 <{context_url['url']}|{context_url['label']}>")

    return "\n".join(lines)


def get_alarm_level(alarm_info, environ):
    """
    Determine the values for conveying the severity of this alarm in Slack.

    In most cases, the severity is defined at setup.  A given alarm, whenever triggered
    is either a warning or an error:
    >>> get_alarm_level({"count": 1}, {"STR_ALARM_LEVEL": "error"})
    (':rotating_light:', 'danger')
    >>> get_alarm_level({"count": 2}, {"STR_ALARM_LEVEL": "warning"})
    ('warning', 'warning')

    However, a "warning" can become an "error" if the scale of the problem is great enough

    >>> get_alarm_level({"count": 11.5}, {"STR_ALARM_LEVEL": "warning", "INT_SUPERPLURAL_THRESHOLD": "10"})
    (':rotating_light:', 'danger')
    """
    if environ["STR_ALARM_LEVEL"] == "error" or is_alarm_count_very_big(
        alarm_info["count"], environ
    ):
        icon_emoji = ":rotating_light:"
        color = "danger"
    else:
        icon_emoji = "warning"
        color = "warning"
    return icon_emoji, color


def is_alarm_count_very_big(alarm_count, environ):
    superplural_threshold = environ.get("INT_SUPERPLURAL_THRESHOLD")
    return superplural_threshold and alarm_count > int(superplural_threshold)


@log_on_error
def main(event, _ctxt=None):
    account = os.environ["ACCOUNT_NAME"]

    alarm = json.loads(event["Records"][0]["Sns"]["Message"])
    alarm_info = get_alarm_info(alarm)

    webhook_url = get_secret_string(secret_id="monitoring/critical_slack_webhook")
    (icon_emoji, color) = get_alarm_level(alarm_info, os.environ)

    slack_payload = {
        "username": f"{account}-{os.environ['STR_ALARM_SLUG']}",
        "icon_emoji": icon_emoji,
        "attachments": [
            {
                "mrkdwn_in": ["text"],
                "color": color,
                "fallback": alarm_info["name"],
                "title": alarm_info["name"],
                "text": create_message(alarm_info),
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
