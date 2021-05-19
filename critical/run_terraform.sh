#!/usr/bin/env bash

AWS_CLI_PROFILE=${AWS_PROFILE:-platform-dev}

EC_API_KEY=$(aws secretsmanager get-secret-value --secret-id elastic_cloud/api_key --profile "$AWS_CLI_PROFILE" --output text --query 'SecretString')

EC_API_KEY=$EC_API_KEY terraform "$@"
