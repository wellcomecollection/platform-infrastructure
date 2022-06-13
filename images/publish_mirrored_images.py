#!/usr/bin/env python
"""
Docker Hub is starting to introduce rate limits for anonymous users. [1]

We pull images from Docker Hub in our CI setup.  We were starting to hit the
rate limits in CI (partly because we run a lot of parallel workers, partly because
our tests pull a lot of different images).

This script mirrors images from Docker Hub to repositories in ECR inside
our AWS account.

Our CI workers are EC2 instances that run inside the same AWS account, so our CI
can pull images from ECR instead of Docker Hub without having to pay AWS egress
charges or hitting Docker Hub rate limits.

If you want to use this script to mirror images from Docker Hub to ECR:

*   Get some local AWS credentials, so that ``boto3.client("ecr")`` returns
    an ECR client authenticated against the account you want to mirror images to
*   Put your own account ID in ``ACCOUNT_ID``
*   Replace the list ``IMAGE_TAGS`` with the tags of every image you want
    to mirror

Wellcome users: run this script as

    python3 publish_mirrored_images.py

[1]: https://www.docker.com/blog/what-you-need-to-know-about-upcoming-docker-hub-rate-limiting/

"""

import base64
import subprocess

import boto3


ACCOUNT_ID = "760097843905"
PLATFORM_ROLE_ARN = "arn:aws:iam::760097843905:role/platform-developer"

# These repositories must be provisioned in terraform/ecr.tf
IMAGE_TAGS = [
    "localstack/localstack",
    "localstack/localstack:0.10.5",
    "localstack/localstack:0.14.2" "scality/s3server:mem-latest",
    "wellcome/build_test_python",
    "wellcome/flake8:latest",
    "wellcome/format_python:112",
    "wellcome/format_python:latest",
    "wellcome/image_builder:23",
    "wellcome/publish_lambda:130",
    "wellcome/sbt_wrapper",
    "wellcome/scalafmt:edge",
    "wellcome/scalafmt:latest",
    "wellcome/tox:latest",
    "zenko/cloudserver:8.1.8",
]


def print(msg):
    # Print in green to make messages stand out.  Based on termcolor.
    import builtins

    builtins.print(f"\x1b[34m*** {msg}\x1b[0m")


def get_ecr_repo_names_in_account(ecr_client, *, account_id):
    """
    Returns a set of all the ECR repository names in an AWS account.
    """
    repo_names = set()

    paginator = ecr_client.get_paginator("describe_repositories")
    for page in paginator.paginate(registryId=account_id):
        for repo in page["repositories"]:
            repo_names.add(repo["repositoryName"])

    return repo_names


def docker_login_to_ecr(ecr_client, *, account_id):
    """
    Authenticate Docker against the ECR repository in a particular account.

    The authorization token obtained from ECR is good for twelve hours, so this
    function is cached to save repeatedly getting a token and running `docker login`
    in quick succession.
    """
    response = ecr_client.get_authorization_token(registryIds=[account_id])

    try:
        auth = response["authorizationData"][0]
    except (IndexError, KeyError):
        raise RuntimeError("Unable to get authorization token from ECR!")

    auth_token = base64.b64decode(auth["authorizationToken"]).decode()
    username, password = auth_token.split(":")

    cmd = [
        "docker",
        "login",
        "--username",
        username,
        "--password",
        password,
        auth["proxyEndpoint"],
    ]

    subprocess.check_call(cmd)


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


def docker(*args):
    """
    Shell out to the Docker CLI.
    """
    subprocess.check_call(["docker"] + list(args))


def mirror_docker_hub_images_to_ecr(ecr_client, *, account_id, image_tags):
    """
    Given the name/tag of images in Docker Hub, mirror those images to ECR.
    """

    print("Authenticating Docker with ECR...")
    docker_login_to_ecr(ecr_client, account_id=account_id)

    for hub_tag in image_tags:
        ecr_tag = f"{account_id}.dkr.ecr.eu-west-1.amazonaws.com/{hub_tag}"
        print(f"Mirroring {hub_tag} to {ecr_tag}")
        docker("pull", hub_tag)
        docker("tag", hub_tag, ecr_tag)
        docker("push", ecr_tag)


if __name__ == "__main__":
    ecr_client = get_aws_client("ecr", role_arn=PLATFORM_ROLE_ARN)
    mirror_docker_hub_images_to_ecr(
        ecr_client=ecr_client, account_id=ACCOUNT_ID, image_tags=IMAGE_TAGS
    )
