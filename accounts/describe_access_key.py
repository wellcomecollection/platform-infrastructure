#!/usr/bin/env python3
"""
This is a tool for finding information about an IAM access key:

    $ python3 describe_access_key.py AKIAIOSFODNN7EXAMPLE
    access key:       AKIAIOSFODNN7EXAMPLE
    account:          acme_corp (1234567890)
    username:         example_user
    key created:      19 May 2020

    IAM permissions:  archivists_s3_upload.iam_permissions.txt

    console:          https://us-east-1.console.aws.amazon.com/iamv2/home#/users/details/example_user?section=permissions
    terraform:        https://github.com/wellcomecollection/archivematica-infrastructure/tree/master/terraform/users



    $ python3 describe_access_key.py not-a-real-key
    access key:       not-a-real-key
    account:          <unknown>

== Motivation ==

We mostly use IAM access keys with S3 clients like FileZilla Pro.

When somebody has an issue, they may know their access key ID but
nothing else.  It's often useful to know the IAM permissions associated
with the key (and where it's defined, in case we need to change them).

This script goes through every IAM user in every account until it finds
a matching access key, then prints some useful information about it.

"""

import json
import sys

import boto3
import termcolor


wellcome_account_names = {
    "299497370133": "workflow",
    "404315009621": "digitisation",
    "760097843905": "platform",
    "756629837203": "catalogue",
    "964279923020": "data",
    "653428163053": "digirati",
    "130871440101": "experience",
    "770700576653": "identity",
    "269807742353": "reporting",
    "975596993436": "storage",
    "782179017633": "microsites",
    "269807742353": "reporting",
    "975596993436": "storage",
    "299497370133": "workflow",
    "782179017633": "microsites",
    "487094370410": "systems_strategy",
}


def get_aws_session(*, role_arn):
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


def get_iam_access_key_info(sess):
    iam = sess.client("iam")

    paginator = iam.get_paginator("list_users")

    for page in paginator.paginate():
        for user in page["Users"]:
            access_keys = iam.list_access_keys(UserName=user["UserName"])

            for key in access_keys["AccessKeyMetadata"]:
                yield {
                    "account_id": account_id,
                    "account_name": account_name,
                    "user": user,
                    "key": key,
                    "iam_client": iam,
                }


def pprint_info(*, key, value):
    print(f"{key}:".ljust(17), end=" ")
    print(termcolor.colored(value, "blue"))


if __name__ == "__main__":
    try:
        access_key_id = sys.argv[1]
    except IndexError:
        sys.exit(f"Usage: {__file__} <ACCESS_KEY_ID>")

    sess = get_aws_session(role_arn="arn:aws:iam::760097843905:role/platform-read_only")
    account_id = sess.client("sts").get_access_key_info(AccessKeyId=access_key_id)[
        "Account"
    ]

    try:
        account_name = wellcome_account_names[account_id]
    except KeyError:
        pprint_info(key="access key", value=access_key_id)
        pprint_info(key="account", value=f"{account_id} (unknown)")
    else:
        account_sess = get_aws_session(
            role_arn=f"arn:aws:iam::{account_id}:role/{account_name}-read_only"
        )

        for info in get_iam_access_key_info(account_sess):
            if info["key"]["AccessKeyId"] == access_key_id:
                tag_resp = info["iam_client"].list_user_tags(
                    UserName=info["user"]["UserName"]
                )
                tags = {t["Key"]: t["Value"] for t in tag_resp["Tags"]}

                user_policies = info["iam_client"].list_user_policies(
                    UserName=info["user"]["UserName"]
                )

                policies = {
                    policy_name: info["iam_client"].get_user_policy(
                        UserName=info["user"]["UserName"], PolicyName=policy_name
                    )
                    for policy_name in user_policies["PolicyNames"]
                }

                pprint_info(key="access key", value=access_key_id)
                pprint_info(key="account", value=f"{account_name} ({account_id})")
                pprint_info(key="username", value=info["user"]["UserName"])
                pprint_info(
                    key="key created",
                    value=info["key"]["CreateDate"].strftime("%d %B %Y"),
                )

                print("")

                policy_document_file = f"{info['user']['UserName']}.iam_permissions.txt"
                with open(policy_document_file, "w") as outfile:
                    for policy_name, policy_description in policies.items():
                        outfile.write(policy_name + "\n")
                        outfile.write(
                            json.dumps(
                                policy_description["PolicyDocument"],
                                indent=2,
                                sort_keys=True,
                            )
                            + "\n\n"
                        )

                pprint_info(key="IAM permissions", value=policy_document_file)

                print("")

                pprint_info(
                    key="console",
                    value=f"https://us-east-1.console.aws.amazon.com/iamv2/home#/users/details/{info['user']['UserName']}?section=permissions",
                )
                pprint_info(
                    key="terraform",
                    value=tags.get("TerraformConfigurationURL", "<unknown>"),
                )

                break
