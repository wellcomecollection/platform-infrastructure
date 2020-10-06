#!/usr/bin/env bash
# This is a BuildKite Agent hook, which gets downloaded from S3 onto the
# running machine, and is run before the start of every job in the pipeline.
# See https://buildkite.com/docs/agent/v3/hooks

set -o errexit
set -o nounset

echo "Hello! I am the agent hook downloaded from S3!"

echo "These are the containers which are running, probably from a previous job:"
docker ps

echo "I'm going to stop these containers now, so this job has a clean start."
docker kill $(docker ps -q) || true

echo "Goodbye! The agent hook is finished now!"
