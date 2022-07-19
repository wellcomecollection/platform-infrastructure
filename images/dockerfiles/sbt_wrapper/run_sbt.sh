#!/usr/bin/env bash

set -o errexit
set -o nounset

source ~/.env.sh

# Merge the built cache into the mounted cache (if present)
rsync -ar --mkpath ~/.sbt.image/ ~/.sbt
rsync -ar --mkpath $COURSIER_DIR.image/ $COURSIER_DIR

# -J-Xss: Stack size (used to hold return addresses, function/method call arguments)
# This is by default in the order of KB, we have experienced OOM & Thread allocation exceptions with lower values
# as some services process large structures via recursive algorithms
# -J-Xms: Minimum (and starting) heap size
# -J-Xmx: Maximum heap size
# The Java heap is the amount of memory allocated to applications running in the JVM.
# Setting maximum and minimum heap size is a shortcut to avoid OOM on startup.
# We've determined the value by experimentation (note containers must be provided at least this much memory).
# -J-XX:MaxMetaspaceSize: Sets the amount of memory used to store compilation metadata (by default unbounded)
# Our use of scala & libraries that use macros means this value can cause OOM errors if a maximum is unset
sbt \
  -batch \
  -J-Xss6M \
  -J-Xms4G \
  -J-Xmx4G \
  -J-XX:MaxMetaspaceSize=2G \
  "$@"
