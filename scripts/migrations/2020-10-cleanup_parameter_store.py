#!/usr/bin/env python
"""
Part of https://github.com/wellcomecollection/platform/issues/4846

At one point we used Parameter Store to record "releases" -- that is, the tag of
the Docker image that should be deployed in ECS.

We no longer use Parameter Store.  This script deletes entries from Parameter Store,
and records their final value (in case they need to be restored).
"""

import datetime
import json

import boto3
import termcolor


ssm_client = boto3.client("ssm")


def get_parameter_store_entries():
    """
    Get all the entries in Parameter Store for an account.

    It returns a 2-tuple: metadata about the parameter from DescribeParameters,
    and the current value of the parameter from GetParameters.
    """
    paginator = ssm_client.get_paginator("describe_parameters")

    for page in paginator.paginate():
        # The DescribeParameters call tells us what parameters exist, but it
        # doesn't tell us what their values are.  We need to make a separate
        # GetParameters call to fetch those.
        resp = ssm_client.get_parameters(
            Names=[param["Name"] for param in page["Parameters"]]
        )

        parameter_values = {param["Name"]: param for param in resp["Parameters"]}

        for param_meta in page["Parameters"]:
            yield param_meta, parameter_values[param_meta["Name"]]


def delete_parameter_store_entry(param_meta, param_value):
    """
    Deletes an entry from Parameter Store, and records it to JSON.
    """
    try:
        deleted_params = json.load(open("2020-10-deleted_parameters.json"))
    except FileNotFoundError:
        deleted_params = []

    parameter_record = {
        "description": param_meta.get("Description"),
        "last_modified": param_meta["LastModifiedDate"].isoformat(),
        "deleted_at": datetime.datetime.now().isoformat(),
        "name": param_meta["Name"],
        "arn": param_value["ARN"],
        "value": param_value["Value"],
    }

    # Print the parameter first, so if we screw up saving it to JSON, we've
    # still got all the critical info.
    print(termcolor.colored(f"Deleting {param_meta['Name']}:", "red"))
    print(json.dumps(parameter_record))

    ssm_client.delete_parameter(Name=param_meta["Name"])

    deleted_params.append(parameter_record)

    with open("2020-10-deleted_parameters.json", "w") as outfile:
        outfile.write(json.dumps(deleted_params, indent=2, sort_keys=True))


if __name__ == "__main__":
    for param_meta, param_value in get_parameter_store_entries():
        if "/images/" not in param_meta["Name"] and not param_meta["Name"].startswith(
            "/releases/"
        ):
            continue

        # A couple of hard-coded exceptions for services that still use SSM.
        if param_meta["Name"] in {
            "/loris/images/latest/loris",
            "/platform/images/latest/nginx_loris",
        }:
            continue

        delete_parameter_store_entry(param_meta=param_meta, param_value=param_value)
