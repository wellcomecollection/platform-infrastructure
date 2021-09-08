import functools
import json
import os
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


def get_ecs_events(sess, *, cluster_arn, service_name):
    """
    Return the events for a given ECS service name.  These are the
    events shown in the "Events" tab of the ECS console.
    """
    client = sess.client("ecs")
    resp = client.describe_services(cluster=cluster_arn, services=[service_name])

    return resp["services"][0]["events"]


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

    for record in event["Records"]:
        ecs_event = json.loads(record["Sns"]["Message"])

        group = ecs_event["detail"]["group"]
        if not group.startswith("service:"):
            continue

        cluster_arn = ecs_event["detail"]["clusterArn"]
        service_name = group[len("service:") :]

        print(f"cluster_arn={cluster_arn!r}, service_name={service_name!r}")

        events = get_ecs_events(
            sess, cluster_arn=cluster_arn, service_name=service_name
        )
        recent_events = events[:10]

        if any(
            "is unable to consistently start tasks successfully" in ev["message"]
            for ev in recent_events
        ):
            webhook_url = get_secret_string(
                secret_id="monitoring/critical_slack_webhook"
            )

            cluster_name = cluster_arn.split(":")[-1]

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
            resp = urllib.request.urlopen(req)
            assert resp.status == 200, resp
