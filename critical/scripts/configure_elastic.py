#!/usr/bin/env python
"""
This script is run by a Terraform local-exec provisioner to create roles/users in
an Elastic Cloud cluster immediately after it's been created.
"""

import functools
import pprint

import boto3

import elasticsearch
from elasticsearch import Elasticsearch


@functools.lru_cache()
def get_aws_client(resource, *, role_arn):
    """
    Get a boto3 client authenticated against the given role.
    """
    sts_client = boto3.client("sts")
    assumed_role_object = sts_client.assume_role(
        RoleArn=role_arn, RoleSessionName="AssumeRoleSession1"
    )

    credentials = assumed_role_object["Credentials"]

    return boto3.client(
        resource,
        aws_access_key_id=credentials["AccessKeyId"],
        aws_secret_access_key=credentials["SecretAccessKey"],
        aws_session_token=credentials["SessionToken"],
    )


def read_secret(secret_id, role_arn):
    """
    Retrieve a secret from Secrets Manager.
    """
    secrets_client = get_aws_client("secretsmanager", role_arn=role_arn)

    return secrets_client.get_secret_value(SecretId=secret_id)["SecretString"]


if __name__ == '__main__':
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"
    secret_prefix = f"elasticsearch/logging"

    es_host = read_secret(f"{secret_prefix}/public_host", role_arn)
    username = read_secret(f"{secret_prefix}/username", role_arn)
    password = read_secret(f"{secret_prefix}/password", role_arn)

    endpoint = f"https://{es_host}:9243"

    es = Elasticsearch(endpoint, http_auth=(username, password))

    security_client = elasticsearch.client.SecurityClient(es)

    role_mapping_config = {
        "enabled" : True,
        "roles" : [
            "kibana_admin",
            "reporting_user",
            "logging_read_only",
            "apm_user",
            "monitoring_user"
        ],
        "rules" : {
            "field" : {
                "realm.name" : "cloud-oidc"
            }
        },
        "metadata" : {
            "version" : 1
        }
    }

    print("Creating role mapping")
    pprint.pprint(security_client.put_role_mapping(
        name='cloud_oidc_to_kibana',
        body=role_mapping_config
    ))
    pprint.pprint(security_client.get_role_mapping('cloud_oidc_to_kibana'))