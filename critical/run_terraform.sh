#!/usr/bin/env bash

AWS_CLI_PROFILE="platform-infrastructure-terraform"
PLATFORM_DEVELOPER_ARN="arn:aws:iam::760097843905:role/platform-developer"

aws configure set region eu-west-1 --profile $AWS_CLI_PROFILE
aws configure set role_arn "$PLATFORM_DEVELOPER_ARN" --profile $AWS_CLI_PROFILE
aws configure set source_profile default --profile $AWS_CLI_PROFILE

EC_API_KEY=$(aws secretsmanager get-secret-value --secret-id elastic_cloud/api_key --profile "$AWS_CLI_PROFILE" --output text --query 'SecretString')

EC_API_KEY=$EC_API_KEY terraform "$@"
