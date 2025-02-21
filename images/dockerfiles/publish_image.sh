#!/usr/bin/env bash

set -o nounset
set -o errexit

AWS_ACCOUNT_ID=760097843905
AWS_PROFILE=platform-developer
CURRENT_COMMIT=$(git rev-parse HEAD)
CURRENT_DIR=$(dirname "$0")

ECR_PRIVATE_PREFIX="$AWS_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/uk.ac.wellcome"
ECR_PUBLIC_PREFIX="public.ecr.aws/l7a1d1z4"
AWS_REGION="eu-west-1"

# get the tag name if passed, and set TAG_NAME if so otherwise use CURRENT_COMMIT
SERVICE_ID=$1
TAG_NAME=${2:-$CURRENT_COMMIT}

# check if service_id matchers a folder in this directory
if [ ! -d "$CURRENT_DIR/$SERVICE_ID" ]; then
  echo "Service ID $SERVICE_ID not found in $CURRENT_DIR"
  exit 1
fi

# check if the folder contains a Dockerfile
if [ ! -f "$CURRENT_DIR/$SERVICE_ID/Dockerfile" ]; then
  echo "Dockerfile not found in $CURRENT_DIR/$SERVICE_ID"
  exit 1
fi

function ecr_login() {
  local aws_profile=$1
  local aws_region=$2
  local is_public=$3

  if [ "$is_public" = true ]; then
    repo_url="public.ecr.aws"
    aws_region="us-east-1"
    service_name="ecr-public"
  else
    service_name="ecr"
    repo_url="$AWS_ACCOUNT_ID.dkr.ecr.$aws_region.amazonaws.com"
  fi

  echo ""
  echo "*** Logging in to ECR ($repo_url in $aws_region) ***"
  echo ""

  aws $service_name get-login-password --region $aws_region --profile $aws_profile | \
    docker login --username AWS --password-stdin $repo_url
}

function push_to_ecr() {
  local service_id=$1
  local tag=$2
  local ecr_prefix=$3
  local ecr_tag="$ecr_prefix/$tag"

  echo ""
  echo "*** Pushing $ecr_tag to ECR ***"
  echo ""

  docker tag "$tag" "$ecr_tag"
  docker push "$ecr_tag"
  docker rmi "$ecr_tag"
}

function build_image() {
  local service_id=$1
  local tag=$2

  echo ""
  echo "*** Building $service_id:$tag ***"
  echo ""

  docker build \
    --tag="$tag" \
    --platform linux/amd64 \
    --platform linux/arm64 \
    $service_id
}

function publish_service() {
  local service_id=$1
  local tag="$service_id:$2"

  build_image "$service_id" "$tag"
  push_to_ecr "$service_id" "$tag" "$ECR_PRIVATE_PREFIX"
  push_to_ecr "$service_id" "$tag" "$ECR_PUBLIC_PREFIX"
}

ecr_login "$AWS_PROFILE" "$AWS_REGION" false
ecr_login "$AWS_PROFILE" "$AWS_REGION" true

if [ $# -eq 0 ]; then
  echo "Usage: publish_service.sh <service_id> [<tag_name>]"
  exit 1
fi

echo ""
echo "*** WARNING! ***"
echo "Updating these images may result in downstream updates to $SERVICE_ID!"
echo "See: https://github.com/search?q=org%3Awellcomecollection%20uk.ac.wellcome%2F$SERVICE_ID&type=code"
echo "Check if consumers are using untagged images before proceeding."
echo "*** WARNING! ***"
echo ""
read -p "Press enter to continue"

publish_service "$SERVICE_ID" "$TAG_NAME"
