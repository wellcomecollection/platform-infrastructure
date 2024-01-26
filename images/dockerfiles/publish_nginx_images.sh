#!/usr/bin/env bash

set -o nounset
set -o errexit

AWS_ACCOUNT_ID=760097843905
AWS_PROFILE=platform-developer
DEV_ROLE_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:role/platform-developer"
ROOT=$(git rev-parse --show-toplevel)
CURRENT_COMMIT=$(git rev-parse HEAD)

ECR_PRIVATE_PREFIX="$AWS_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/uk.ac.wellcome"
ECR_PUBLIC_PREFIX="public.ecr.aws/l7a1d1z4"
AWS_REGION="eu-west-1"

SERVICE_IDS="frontend frontend_identity"


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
  local tag=$1
  local ecr_prefix=$2
  local ecr_tag="$ecr_prefix/$tag"

  echo ""
  echo "*** Pushing $ecr_tag to ECR ***"
  echo ""

  docker tag "$tag" "$ecr_tag"
  docker push "$ecr_tag"
  docker rmi "$ecr_tag"
}

function build_template() {
  local service_id=$1
  local tag=$2
  local template_file="$service_id.nginx.conf"

  echo ""
  echo "*** Building $template_file ***"
  echo ""

  docker build \
    --tag="$tag" \
    --build-arg CONFIG_TEMPLATE="${template_file}" \
    --file nginx/template.Dockerfile \
    nginx
}

function publish_service() {
  local service_id=$1
  local template_file="$service_id.nginx.conf"
  local tag="nginx_$service_id:$CURRENT_COMMIT"

  build_template "$service_id" "$tag"
  push_to_ecr "$tag" "$ECR_PRIVATE_PREFIX"
  push_to_ecr "$tag" "$ECR_PUBLIC_PREFIX"
}

echo ""
echo "*** WARNING! ***"
echo "Updating these images may result in downstream updates!"
echo "Check if consumers are using untagged images before proceeding."
echo "See: https://github.com/search?q=org%3Awellcomecollection%20uk.ac.wellcome%2Fnginx&type=code"
echo "*** WARNING! ***"
echo ""
read -p "Press enter to continue"

ecr_login "$AWS_PROFILE" "$AWS_REGION" false
ecr_login "$AWS_PROFILE" "$AWS_REGION" true

for SERVICE_ID in $SERVICE_IDS
do
  publish_service "$SERVICE_ID"
done
