import datetime

import boto3


def get_aws_session(*, role_arn):
    """
    Get a boto3 Session authenticated with the given role ARN.
    """
    sts_client = boto3.client("sts")
    assumed_role_object = sts_client.assume_role(
        RoleArn=role_arn, RoleSessionName="AssumeRoleSession1"
    )
    credentials = assumed_role_object["Credentials"]
    return boto3.Session(
        aws_access_key_id=credentials["AccessKeyId"],
        aws_secret_access_key=credentials["SecretAccessKey"],
        aws_session_token=credentials["SessionToken"],
    )


def get_last_four_months_of_bills(*, role_arn):
    """
    Retrieve the last four months of total costs for the given AWS role.
    """
    sess = get_aws_session(role_arn=role_arn)
    client = sess.client("ce")

    this_month_start = datetime.date.today().replace(day=1)

    if this_month_start.month > 4:
        four_months_ago = this_month_start.replace(month=this_month_start.month - 4)
    else:
        four_months_ago = this_month_start.replace(year=this_month_start.year - 1, month = 12 - this_month_start.month)

    resp = client.get_cost_and_usage(
        TimePeriod={
            "Start": four_months_ago.isoformat(),
            "End": this_month_start.isoformat(),
        },
        Granularity="MONTHLY",
        Metrics=["UnblendedCost"],
    )

    result = {}

    for entry in resp["ResultsByTime"]:
        start = datetime.datetime.strptime(entry["TimePeriod"]["Start"], "%Y-%m-%d")
        assert entry["Total"]["UnblendedCost"]["Unit"] == "USD"
        result[(start.year, start.month)] = float(
            entry["Total"]["UnblendedCost"]["Amount"]
        )

    return result


def main(_event, _context):
    billing_data = {}

    for account_id, account_name in [
        ("760097843905", "platform"),
        # ("catalogue", "756629837203"),
        # ("workflow", "299497370133"),
        # ("storage", "975596993436"),
        # ("experience", "130871440101"),
        # ("identity", "770700576653"),
        # ("dam_prototype", "241906670800"),
    ]:
        role_arn = f"arn:aws:iam::{account_id}:role/{account_name}-costs_report_lambda"

        billing_data[account_name] = get_last_four_months_of_bills(role_arn=role_arn)

    from pprint import pprint
    pprint(billing_data)
