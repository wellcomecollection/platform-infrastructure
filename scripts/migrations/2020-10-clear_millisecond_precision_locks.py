#!/usr/bin/env python
"""
In scala-libs v14.1.0, we changed our Dynamo formatting to store an Instant as
seconds since the epoch, not milliseconds.  This means that if we specify
a "expiryTime" on an item, we can use a DynamoDB TTL to automatically delete the
item, rather than handling it ourselves.

However, any leftover items will have timestamp which measures milliseconds since
the epoch, which parses as thousands of years in the future if read as seconds
since the epoch.

This script walks a table, and deletes all the items where a given attribute
appears to be a millisecond timestamp.
"""

import decimal
import json
import time

import boto3


def get_items(dynamodb_client, *, table_name):
    """
    Get all the items in a DynamoDB table.
    """
    paginator = dynamodb_client.get_paginator("scan")

    for page in paginator.paginate(TableName=table_name):
        yield from page["Items"]


def has_millisecond_precision_timestamp(item, *, attribute_name):
    return (
        isinstance(item[attribute_name], decimal.Decimal) and
        item[attribute_name] > time.time() * 100
    )


class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, decimal.Decimal):
            return int(obj)


if __name__ == "__main__":
    table_name = "storage-staging_versioner_lock_table"
    attribute_name = "created"

    dynamodb_client = boto3.resource("dynamodb").meta.client

    resp = dynamodb_client.describe_table(TableName=table_name)

    key_fields = [key["AttributeName"] for key in resp["Table"]["KeySchema"]]

    with open("2020-10-millisecond_precision_locks.json", "a") as outfile:
        for item in get_items(dynamodb_client, table_name=table_name):
            if not has_millisecond_precision_timestamp(
                item, attribute_name=attribute_name
            ):
                continue

            outfile.write(json.dumps({"table_name": table_name, "item": item}, cls=DecimalEncoder) + "\n")

            dynamodb_client.delete_item(
                TableName=table_name,
                Key={kf: item[kf] for kf in key_fields}
            )
