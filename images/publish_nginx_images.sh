#!/usr/bin/env bash

set -o nounset

DEV_ROLE_ARN="arn:aws:iam::760097843905:role/platform-developer"
ROOT=$(git rev-parse --show-toplevel)

ECR_PRIVATE_PREFIX="760097843905.dkr.ecr.eu-west-1.amazonaws.com/uk.ac.wellcome"
ECR_PUBLIC_PREFIX="public.ecr.aws/l7a1d1z4"

SERVICE_IDS="apigw experience grafana"

echo ""
echo "*** WARNING! ***"
echo "Updating these images may result in downstream updates!"
echo "This will affect multiple public facing products (including wc.org)"
echo "*** WARNING! ***"
echo ""
read -p "Press enter to continue."



echo ""
echo "*** Logging in to ECR Private ***"
echo ""
AWS_PROFILE=platform-developer aws ecr get-login --no-include-email | bash

echo ""
echo "*** Logging in to ECR Public ***"
echo ""

# We have to log in with us-east-1 because that's where ECR Public lives.
# See https://docs.aws.amazon.com/AmazonECR/latest/public/getting-started-cli.html#cli-authenticate-registry
AWS_PROFILE=platform-developer aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws



for SERVICE_ID in $SERVICE_IDS
do

  echo ""
  echo "*** Publishing $SERVICE_ID ***"
  echo ""

  CURRENT_COMMIT=$(git rev-parse HEAD)
  TAG="nginx_$SERVICE_ID:$CURRENT_COMMIT"

  docker build --tag="$TAG" --file "nginx/$SERVICE_ID.Dockerfile" nginx

  echo ""
  echo "*** Publishing $SERVICE_ID image to ECR Private ***"
  echo ""

  ECR_PRIVATE_TAG="$ECR_PRIVATE_PREFIX/nginx_$SERVICE_ID:$CURRENT_COMMIT"

  docker tag "$TAG" "$ECR_PRIVATE_TAG"
  docker push "$ECR_PRIVATE_TAG"
  docker rmi "$ECR_PRIVATE_TAG"

  if [[ "$SERVICE_ID" == "apigw" ]]
  then
    echo ""
    echo "*** Publishing $SERVICE_ID image to ECR Public ***"
    echo ""

    ECR_PUBLIC_TAG="$ECR_PUBLIC_PREFIX/nginx_$SERVICE_ID:$CURRENT_COMMIT"

    docker tag "$TAG" "$ECR_PUBLIC_TAG"
    docker push "$ECR_PUBLIC_TAG"
    docker rmi "$ECR_PUBLIC_TAG"
  fi
done
