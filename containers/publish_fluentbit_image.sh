#!/usr/bin/env bash

set -o nounset

DEV_ROLE_ARN="arn:aws:iam::760097843905:role/platform-developer"
ROOT=$(git rev-parse --show-toplevel)

echo ""
echo "*** WARNING! ***"
echo "Updating these images may result in downstream updates!"
echo "This will affect multiple public facing products (including wc.org)"
echo "*** WARNING! ***"
echo ""
read -p "Press enter to continue."

echo ""
echo "*** Publishing fluentbit ***"
echo ""

"$ROOT"/scripts/docker_run.py \
      --dind --root -- \
      wellcome/image_builder:23 \
            --project=fluentbit \
            --file=containers/fluentbit/Dockerfile

"$ROOT"/scripts/docker_run.py \
      --aws --root --dind -- \
      wellcome/publish_service:86 \
        --service_id=fluentbit \
          --project_id=platform \
          --account_id=760097843905 \
          --region_id=eu-west-1 \
          --namespace=uk.ac.wellcome \
          --role_arn="$DEV_ROLE_ARN" \
          --label=latest


