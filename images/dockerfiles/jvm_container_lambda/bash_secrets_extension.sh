#!/usr/bin/env bash

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

set -euo pipefail

OWN_FILENAME="$(basename $0)"
LAMBDA_EXTENSION_NAME="$OWN_FILENAME" # (external) extension name has to match the filename
TMP_FILE=/tmp/$OWN_FILENAME

# Graceful Shutdown
_term() {
  echo "[${LAMBDA_EXTENSION_NAME}] Received SIGTERM"
  # forward SIGTERM to child procs and exit
  kill -TERM "$PID" 2>/dev/null
  echo "[${LAMBDA_EXTENSION_NAME}] Exiting"
  exit 0
}

forward_sigterm_and_wait() {
  trap _term SIGTERM
  wait "$PID"
  trap - SIGTERM
}

# Initialization
# To run any extension processes that need to start before the runtime initializes, run them before the /register
echo "[${LAMBDA_EXTENSION_NAME}] Initialization"

# Extract secret value from environment variable and write to config file
extract_secret_value_to_config() {
  local env_var=$1
  local env_var_value
  local env_var_key
  local secret_key
  local secret_value

  env_var_value=$(echo "$env_var" | cut -d= -f2)
  env_var_key=$(echo "$env_var" | cut -d= -f1)

  if [[ $env_var_value == "secret:"* ]]; then
    echo "[${LAMBDA_EXTENSION_NAME}] Extracting secret value from environment variable: $env_var_key" > /dev/stdout
    secret_key=$(echo "$env_var_value" | cut -d: -f2)
    secret_value=$(aws secretsmanager get-secret-value --secret-id "$secret_key" --query SecretString --output text)
    if [[ -z "$secret_value" ]]; then
      echo "[${LAMBDA_EXTENSION_NAME}] Secret not found: $secret_key" > /dev/stdout
      exit 1
    fi
    echo "$env_var_key=\"$secret_value\"" >> /tmp/config
  fi
}

# Create a configuration file with secrets
create_config_file() {
  echo "[${LAMBDA_EXTENSION_NAME}] Creating config file :)" > /dev/stdout
  local env_vars
  local env_var

  # Ensure the file exists, and is empty
  touch /tmp/config
  echo -n > /tmp/config

  env_vars=$(printenv)
  for env_var in $env_vars; do
    extract_secret_value_to_config "$env_var"
  done
}

create_config_file

# Registration
# The extension registration also signals to Lambda to start initializing the runtime.
HEADERS="$(mktemp)"
echo "[${LAMBDA_EXTENSION_NAME}] Registering at http://${AWS_LAMBDA_RUNTIME_API}/2020-01-01/extension/register"
curl -sS -LD "$HEADERS" \
  -XPOST "http://${AWS_LAMBDA_RUNTIME_API}/2020-01-01/extension/register" \
  --header "Lambda-Extension-Name: ${LAMBDA_EXTENSION_NAME}" \
  -d "{ \"events\": [\"SHUTDOWN\"]}" > "$TMP_FILE"

RESPONSE=$(<"$TMP_FILE")
# Extract Extension ID from response headers
EXTENSION_ID=$(grep -Fi Lambda-Extension-Identifier "$HEADERS" | tr -d '[:space:]' | cut -d: -f2)
echo "[${LAMBDA_EXTENSION_NAME}] Registration response: ${RESPONSE} with EXTENSION_ID $(grep -Fi Lambda-Extension-Identifier "$HEADERS" | tr -d '[:space:]' | cut -d: -f2)"

# Event processing
# Continuous loop to wait for events from Extensions API
while true
do
  echo "[${LAMBDA_EXTENSION_NAME}] Waiting for event. Get /next event from http://${AWS_LAMBDA_RUNTIME_API}/2020-01-01/extension/event/next"

  # Get an event. The HTTP request will block until one is received
  curl -sS -L -XGET "http://${AWS_LAMBDA_RUNTIME_API}/2020-01-01/extension/event/next" --header "Lambda-Extension-Identifier: ${EXTENSION_ID}" > $TMP_FILE &
  PID=$!
  forward_sigterm_and_wait

  EVENT_DATA=$(<"$TMP_FILE")
  if [[ $EVENT_DATA == *"SHUTDOWN"* ]]; then
    echo "[extension: ${LAMBDA_EXTENSION_NAME}] Received SHUTDOWN event. Exiting."  1>&2;
    exit 0 # Exit if we receive a SHUTDOWN event
  fi
done
