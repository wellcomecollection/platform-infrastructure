#!/usr/bin/env python
"""
Docker Hub enforces rate limits for unauthenticated users, and our build system
will hit those limits.

This script mirrors the images we care about into ECR repositories in
our AWS accounts, so we're not affected by those rate limits.
"""

import functools
import subprocess

import boto3
import click


IMAGES = [
    "hashicorp/terraform:light",
    "localstack/localstack",
    "peopleperhour/dynamodb",
    "rodolpheche/wiremock",
    "s12v/elasticmq",
    "wellcome/build_test_python",
    "wellcome/flake8:latest",
    "wellcome/format_python:112",
    "wellcome/image_builder:23",
    "wellcome/publish_lambda:130",
    "wellcome/sbt_wrapper",
    "wellcome/scalafmt:edge",
    "wellcome/weco-deploy:5.5.7",
    "zenko/cloudserver:8.1.8",
]

ACCOUNTS = {"760097843905": "platform"}


def docker(*args):
    subprocess.check_call(["docker"] + list(args))


def print(msg):
    click.echo(click.style(f"*** {msg}", "blue"))


@functools.lru_cache()
def get_aws_client(resource, *, role_arn):
    assumed_role_object = boto3.client("sts").assume_role(
        RoleArn=role_arn, RoleSessionName="AssumeRoleSession1"
    )
    credentials = assumed_role_object["Credentials"]
    return boto3.client(
        resource,
        aws_access_key_id=credentials["AccessKeyId"],
        aws_secret_access_key=credentials["SecretAccessKey"],
        aws_session_token=credentials["SessionToken"],
    )


def ensure_ecr_repos_exist(ecr_client, *, account_id, account_name, image_tags):
    """
    Ensure we have ECR image repositories that we can mirror images into.
    """
    known_repos = set()

    paginator = ecr_client.get_paginator("describe_repositories")
    for page in paginator.paginate(registryId=account_id):
        for repo in page["repositories"]:
            known_repos.add(repo["repositoryName"])

    for tag in image_tags:
        name = tag.split(":")[0]  # eg hashicorp/terraform:light ~> hashicorp/terraform
        if name not in known_repos:
            ecr_client.create_repository(repositoryName=name)


if __name__ == "__main__":
    for account in ACCOUNTS.values():
        print(f"Logging in to ECR in the {account} account")
        subprocess.check_call(
            f"eval $(AWS_PROFILE={account}-dev aws ecr get-login --no-include-email)",
            shell=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    for account_id, account_name in ACCOUNTS.items():
        print(f"Creating ECR repos in the {account} account")

        role_arn = f"arn:aws:iam::{account_id}:role/{account_name}-publisher"
        ecr_client = get_aws_client("ecr", role_arn=role_arn)

        ensure_ecr_repos_exist(
            ecr_client,
            account_id=account_id,
            account_name=account_name,
            image_tags=IMAGES,
        )

    for image_tag in IMAGES:
        print(f"Pulling {image_tag}")
        docker("pull", image_tag)

        for account_id, account_name in ACCOUNTS.items():
            ecr_image_tag = f"{account_id}.dkr.ecr.eu-west-1.amazonaws.com/{image_tag}"
            print(f"Pushing {image_tag} to {ecr_image_tag} ({account_name})")
            docker("tag", image_tag, ecr_image_tag)
            docker("push", ecr_image_tag)
