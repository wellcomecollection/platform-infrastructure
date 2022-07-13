#!/usr/bin/env bash

set -o errexit
set -o nounset

apk add --no-cache curl

curl --location "https://github.com/sbt/sbt/releases/download/v$SBT_VERSION/sbt-$SBT_VERSION.tgz" \
  | gunzip \
  | tar -x -C /usr/local

# This flag is to avoid getting an error from sbt if this script is
# executed from the root directory:
#
#     java.lang.IllegalStateException: cannot run sbt from root directory
#     without -Dsbt.rootdir=true; see sbt/sbt#1458
#
# We're not doing anything useful with sbt here except fetching it once
# so it's added to the cache that's baked in the image, so we get it on
# image pull rather than fetching it each time.
#
# In particular, we want to avoid the dreaded:
#
#     getting org.scala-sbt sbt 1.4.1  (this may take some time)...
#
sbt -Dsbt.rootdir=true sbtVersion
COURSIER_DIR=$(sbt -error -Dsbt.rootdir=true "print csrCacheDirectory")
echo "export COURSIER_DIR=$COURSIER_DIR" > ~/.env.sh

# When we run the Docker image, we mount ~/.sbt and the coursier cache dir inside the
# container.  To avoid clobbering the version of sbt that's downloaded
# as part of the image, move the in-image caches off to the side.
#
# We'll move them back into place before running any sbt commands,
# and after we've mounted the host caches.
mv ~/.sbt ~/.sbt.image
mv $COURSIER_DIR $COURSIER_DIR.image

apk del curl
