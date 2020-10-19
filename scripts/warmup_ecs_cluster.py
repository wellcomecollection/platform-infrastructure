#!/usr/bin/env python
"""
A lot of the services we run in ECS are started/stopped by Autoscaling, and
scale down to zero when they're not in use.

While good for costs, it's a pain for debugging -- if you've deployed a new
service, you need to wait for it to scale up before you can see the effect of
your changes.

This script allows you to temporarily "warm up" the services in our ECS cluster --
that is, set the min capacity to 1 so services will constantly be running.

The same script can "cool down" a cluster -- turn the capacity back down to the
min defined by Terraform.
"""

import os
import sys

import click
import hcl
import inquirer

from _aws import get_aws_client, get_s3_object, ACCOUNT_IDS
from _ecs import get_ecs_cluster_arns


def choose(*, question, choices):
    """
    Ask the user to choose from a series of choices.
    """
    answers = inquirer.prompt(
        [inquirer.List("choose", message=question, choices=sorted(choices))]
    )
    return answers["choose"]


def _find_autoscaling_config(tfstate):
    """
    Returns the min capacity of every service defined in the Terraform state.
    """
    min_capacities = {}

    for res in tfstate["resources"]:
        if res["type"] == "aws_appautoscaling_target":
            assert len(res["instances"]) <= 1, res
            try:
                attributes = res["instances"][0]["attributes"]
            except IndexError:
                continue
            min_capacities[attributes["id"]] = attributes["min_capacity"]

    return min_capacities


def _get_tfstate_location(*, account_name, cluster_name):
    if account_name == "platform":
        tfstate_bucket = "wellcomecollection-platform-infra"

        tf_key_lookup = {
            "calm-adapter": "terraform/calm_adapter.tfstate",
            "reindexer": "terraform/catalogue/reindexer.tfstate",
            "mets-adapter": "terraform/catalogue/mets_adapter.tfstate",
        }

        if cluster_name.startswith("catalogue-"):
            tfstate_key = "terraform/catalogue/pipeline.tfstate"
        elif cluster_name.startswith("sierra-adapter-"):
            tfstate_key = "terraform/sierra_adapter.tfstate"
        elif cluster_name in tf_key_lookup:
            tfstate_key = tf_key_lookup[cluster_name]

    elif account_name == "storage":
        tfstate_bucket = "wellcomecollection-storage-infra"

        tfstate_key = {
            "storage-staging": "terraform/storage-service/stack_staging.tfstate",
            "storage-prod": "terraform/storage-service/stack_prod.tfstate",
        }

    try:
        return {"bucket": tfstate_bucket, "key": tfstate_key}
    except NameError:
        sys.exit(f"Don't know tfstate location for {cluster_name}")


def _get_tf_min_capacities(*, account_name, role_arn, cluster_name):
    """
    Ask the Terraform: what's the min these services should ever be warmed to?
    """
    tfstate_location = _get_tfstate_location(
        account_name=account_name, cluster_name=cluster_name
    )

    s3_client = get_aws_client("s3", role_arn=role_arn)
    tfstate = hcl.loads(get_s3_object(s3_client, **tfstate_location))

    min_capacities = _find_autoscaling_config(tfstate)

    return {
        name: capacity
        for name, capacity in min_capacities.items()
        if name.startswith(f"service/{cluster_name}/")
    }


def _get_current_scalable_targets(autoscaling_client, *, service_names):
    min_capacities = {}

    paginator = autoscaling_client.get_paginator("describe_scalable_targets")

    for page in paginator.paginate(
        ResourceIds=list(service_names), ServiceNamespace="ecs"
    ):
        for target in page["ScalableTargets"]:
            min_capacities[target["ResourceId"]] = target

    return min_capacities


def warm_ecs_cluster(*, account_name, role_arn, cluster_name):
    """
    Warm or cool an ECS cluster.
    """
    tf_min_capacities = _get_tf_min_capacities(
        account_name=account_name, role_arn=role_arn, cluster_name=cluster_name
    )

    print(
        f"Detected autoscaling config for {click.style(str(len(tf_min_capacities)), 'blue')} service{'s' if len(tf_min_capacities) > 1 else ''}"
    )

    autoscaling_client = get_aws_client("application-autoscaling", role_arn=role_arn)
    current_scalable_targets = _get_current_scalable_targets(
        autoscaling_client, service_names=tf_min_capacities.keys()
    )

    common_prefix = os.path.commonprefix(list(tf_min_capacities.keys()))

    for name, tf_min in sorted(tf_min_capacities.items()):
        display_name = (
            name[len(common_prefix) :] or name[len(f"service/{cluster_name}/") :]
        )

        target = current_scalable_targets[name]
        curr_min = target["MinCapacity"]

        if tf_min == 0 and curr_min == 0:
            print(click.style("warming", "green"), display_name)
            new_min_capacity = 1
        elif tf_min == 0 and curr_min > 0:
            print(click.style(f"cooling", "blue"), display_name)
            new_min_capacity = 0
        else:
            print(
                click.style("???????", "red"),
                f"{name}, tf_min={tf_min}, curr_min={curr_min}",
            )
            continue

        del target["CreationTime"]
        target["MinCapacity"] = new_min_capacity
        autoscaling_client.register_scalable_target(**target)


@click.command()
@click.option(
    "--account",
    "account_name",
    type=click.Choice(["platform", "storage", "catalogue"]),
    prompt="Which account are you working in?",
)
@click.option("--cluster", "cluster_name")
def main(account_name, cluster_name):
    account_id = ACCOUNT_IDS[account_name]
    role_arn = f"arn:aws:iam::{account_id}:role/{account_name}-developer"

    ecs_client = get_aws_client("ecs", role_arn=role_arn)

    ecs_cluster_names = {arn.split("/")[-1] for arn in get_ecs_cluster_arns(ecs_client)}

    if cluster_name is not None:
        if cluster_name not in ecs_cluster_names:
            sys.exit(
                f"There is no cluster named {cluster_name} in the {account_name} account"
            )
    else:
        cluster_name = choose(
            question="Which ECS cluster would you like to warm?",
            choices=ecs_cluster_names,
        )

    warm_ecs_cluster(
        account_name=account_name, role_arn=role_arn, cluster_name=cluster_name
    )


if __name__ == "__main__":
    main()
