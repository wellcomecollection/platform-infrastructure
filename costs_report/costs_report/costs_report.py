import collections
import datetime
import json
import re
import urllib.error
import urllib.request

import boto3
import tabulate


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
        four_months_ago = this_month_start.replace(
            year=this_month_start.year - 1, month=12 - this_month_start.month
        )

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


def get_secret_string(sess, *, secret_id):
    """
    Look up the value of a SecretString in Secrets Manager.
    """
    client = sess.client("secretsmanager")
    return client.get_secret_value(SecretId=secret_id)["SecretString"]


def _get_elastic_cloud_costs_for_range(
    *,
    from_date,
    to_date,
    api_key,
    organisation_id,
):
    # See https://www.elastic.co/guide/en/cloud/current/Billing_Costs_Analysis.html
    url = f"https://api.elastic-cloud.com/api/v1/billing/costs/{organisation_id}?from={from_date.isoformat()}T00:00:00Z&to={to_date.isoformat()}T00:00:00Z"
    headers = {"Authorization": f"ApiKey {api_key}"}
    req = urllib.request.Request(url, headers=headers)

    resp = urllib.request.urlopen(req)
    result = json.load(resp)

    return result["costs"]["total"]


def get_elastic_cloud_bill(date_blocks):
    """
    Retrieve the last four months of total costs for Elastic Cloud.
    """
    sess = boto3.Session()

    api_key = get_secret_string(sess, secret_id="elastic_cloud/api_key")
    organisation_id = get_secret_string(sess, secret_id="elastic_cloud/organisation_id")

    result = {}

    for year, month in date_blocks:
        from_date = datetime.date(year, month, day=1)

        if month == 12:
            to_date = datetime.date(year + 1, month=1, day=1)
        else:
            to_date = datetime.date(year, month + 1, day=1)

        try:
            result[(year, month)] = _get_elastic_cloud_costs_for_range(
                from_date=from_date,
                to_date=to_date,
                api_key=api_key,
                organisation_id=organisation_id,
            )
        except urllib.error.HTTPError:
            # Elastic Cloud only supports getting up to three months of
            # billing data with this API at time of writing.
            #
            # If we do get an error, assume it's because we exceeded three
            # months, and mark the cost as zero.  If Elastic ever extend
            # the supported range, this will start working.
            result[(year, month)] = 0

    return result


def average(values):
    return sum(values) / len(values)


def pprint_currency(v):
    if isinstance(v, float):
        orig = "%.2f" % v
    else:
        orig = v

    new = re.sub(r"^(-?\d+)(\d{3})", fr"\g<1>,\g<2>", orig)
    if orig == new:
        return new
    else:
        return pprint_currency(new)


def _render_row(label, per_month_bills):
    *prev_months, this_month = sorted(per_month_bills.items())

    # We skip 0 values when computing the average -- this either means
    # the account didn't exist in that month, or we don't have billing
    # data for that month.
    prev_month_average = average([total for _, total in prev_months if total != 0])

    _, this_month_total = this_month

    # If 95% of the previous month is bigger than this month, then
    # we've saved at least 5%
    if prev_month_average * 0.95 > this_month_total:
        reduction = int((1 - this_month_total / prev_month_average) * 100)
        gain, loss = f"↓ {reduction:2d}%", ""

    # If 105% of the previous months is less than this month, then
    # we've spent at least 5% more
    elif prev_month_average * 1.05 <= this_month_total:
        extra_spend = int((this_month_total / prev_month_average - 1) * 100)
        gain, loss = "", f"↟↟ {extra_spend:2d}%"

    else:
        gain, loss = "", ""

    return [
        label,
        pprint_currency(prev_month_average),
        pprint_currency(this_month_total),
        gain,
        loss,
    ]


def create_billing_table(billing_data):
    """
    Returns a string that contains a table that describes the billing data.

    This table is meant for printing in a monospaced font.
    """
    lines = []

    rows = [
        _render_row(account_name, per_month_bills)
        for account_name, per_month_bills in billing_data.items()
    ]

    # Sort the rows so the most expensive account is at the top
    rows = sorted(rows, key=lambda r: float(r[2].replace(",", "")), reverse=True)

    # Add a footer row that shows the total.
    total_bills = collections.defaultdict(int)
    for per_month_bills in billing_data.values():
        for month, amount in per_month_bills.items():

            # We may have some zero-values in here; if so, backfill with
            # the average of the non-zero bills for this month.  This avoids
            # any zero values dragging down the average.
            if amount == 0:
                total_bills[month] = average(
                    [v for v in per_month_bills.values() if v > 0]
                )
            else:
                total_bills[month] += amount

    rows.append(
        ["-------------", "-------------------", "----------------", "------", "------"]
    )
    rows.append(_render_row("TOTAL", total_bills))

    return tabulate.tabulate(
        rows,
        headers=["account", "prev 3 months ($)", "last month ($)", "", ""],
        floatfmt=".2f",
        colalign=("left", "right", "right", "right"),
    )


def main(_event, _context):
    billing_data = {}

    for account_id, account_name in [
        ("760097843905", "platform"),
        ("756629837203", "catalogue"),
        ("975596993436", "storage"),
        ("299497370133", "workflow"),
        ("130871440101", "experience"),
        ("770700576653", "identity"),
        ("241906670800", "dam_prototype"),
    ]:
        role_arn = f"arn:aws:iam::{account_id}:role/{account_name}-costs_report_lambda"

        billing_data[account_name] = get_last_four_months_of_bills(role_arn=role_arn)

    billing_data["elastic cloud"] = get_elastic_cloud_bill(
        date_blocks=billing_data["platform"].keys()
    )
    table = create_billing_table(billing_data)

    this_month = datetime.date.today() - datetime.timedelta(days=28)

    slack_payload = {
        "username": "costs-report",
        "icon_emoji": ":money_with_wings:",
        "attachments": [
            {
                "title": f"Costs report for {this_month.strftime('%B %Y')}",
                "fields": [{"value": f"```\n{table}\n```"}],
            }
        ],
    }

    sess = boto3.Session()
    webhook_url = get_secret_string(sess, secret_id="slack/wc-platform-hook")

    print("Sending message %s" % json.dumps(slack_payload))

    req = urllib.request.Request(
        webhook_url,
        data=json.dumps(slack_payload).encode("utf8"),
        headers={"Content-Type": "application/json"},
    )
    resp = urllib.request.urlopen(req)
    assert resp.status == 200, resp


if __name__ == "__main__":
    main(None, None)
