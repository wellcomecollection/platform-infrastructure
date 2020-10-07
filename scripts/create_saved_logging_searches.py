#!/usr/bin/env python
"""
Create saved searches for each of our services in our logging cluster.
"""

import getpass
import json
import re

import boto3
import httpx
import termcolor


def get_cluster_arns(ecs_client):
    cluster_paginator = ecs_client.get_paginator("list_clusters")

    for page in cluster_paginator.paginate():
        yield from page["clusterArns"]


def get_service_arns_in_cluster(ecs_client, *, cluster_arn):
    service_paginator = ecs_client.get_paginator("list_services")

    for page in service_paginator.paginate(cluster=cluster_arn):
        yield from page["serviceArns"]


def get_service_names():
    """
    Query the ECS clusters in our different accounts and get the service names
    for each of them.  This is more thorough than querying Elasticsearch, because
    it will find every service rather than just the ones that have logged recently.
    """
    for role_arn in [
        "arn:aws:iam::756629837203:role/catalogue-read_only",
        "arn:aws:iam::760097843905:role/platform-read_only",
        "arn:aws:iam::975596993436:role/storage-read_only",
    ]:
        ecs_client = get_aws_client("ecs", role_arn=role_arn)

        for cluster_arn in get_cluster_arns(ecs_client):
            for service_arn in get_service_arns_in_cluster(
                ecs_client, cluster_arn=cluster_arn
            ):

                # The service ARN is typically something like
                #
                #     arn:aws:ecs:eu-west-1:756629837203:service/snapshot_generator
                #
                # We only care about the service name, so discard the rest.
                yield service_arn.split("/")[-1]


def get_aws_client(resource, *, role_arn):
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


def create_saved_search_for(client, *, service_name):
    # https://www.elastic.co/guide/en/kibana/master/saved-objects-api-create.html
    # I got the searchSourceJSON block by creating a saved search in the
    # Kibana UI, then retrieving it through the "find Saved Objects" API.
    return client.post(
        f"/api/saved_objects/search/{service_name}",
        json={
            "attributes": {
                "columns": ["_source"],
                "title": f"service: {service_name}",
                "kibanaSavedObjectMeta": {
                    "searchSourceJSON": json.dumps(
                        {
                            "highlightAll": True,
                            "version": True,
                            "query": {"query": "", "language": "kuery"},
                            "indexRefName": "kibanaSavedObjectMeta.searchSourceJSON.index",
                            "filter": [
                                {
                                    "query": {
                                        "match_phrase": {"service_name": service_name}
                                    },
                                    "$state": {"store": "appState"},
                                    "meta": {
                                        "alias": None,
                                        "negate": False,
                                        "disabled": False,
                                        "type": "phrase",
                                        "key": "service_name",
                                        "params": {"query": service_name},
                                        "indexRefName": "kibanaSavedObjectMeta.searchSourceJSON.filter[0].meta.index",
                                    },
                                }
                            ],
                        }
                    )
                },
            },
            "references": [
                {
                    "id": "978cbc80-af0d-11ea-b454-cb894ee8b269",
                    "name": "kibanaSavedObjectMeta.searchSourceJSON.index",
                    "type": "index-pattern",
                },
                {
                    "id": "978cbc80-af0d-11ea-b454-cb894ee8b269",
                    "name": "kibanaSavedObjectMeta.searchSourceJSON.filter[0].meta.index",
                    "type": "index-pattern",
                },
            ],
        },
        headers=[("kbn-xsrf", "true")],
        params={"overwrite": "true"},
    )


if __name__ == "__main__":
    username = getpass.getpass("Kibana username: ")
    password = getpass.getpass("Kibana password: ")
    endpoint = getpass.getpass("Kibana endpoint: ")

    client = httpx.Client(base_url=endpoint, auth=httpx.BasicAuth(username, password))

    for service_name in get_service_names():

        # Skip services that don't log to Elasticsearch.
        if any(s in service_name for s in ("logstash_transit", "loris")):
            continue

        # For catalogue services that include a date in the service name
        # (e.g. catalogue-20200701_matcher), replace this with an asterisk (*)
        # as a wildcard search in ES.
        #
        # This avoids us having to recreate the saved searches every time
        # we redeploy in the catalogue.
        service_name = re.sub(
            r"([-_])[0-9-]+([-_]?)", r"\g<1>*\g<2>", service_name
        ).strip("-")

        print(f"Creating a saved search for {termcolor.colored(service_name, 'blue')}")
        create_saved_search_for(client, service_name=service_name)
