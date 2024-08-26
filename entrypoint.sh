#!/bin/bash

RUNNER_VOLUME_DIR="/home/podman/runner"
RUNNER_INSTALL_DIR="/home/podman/actions-runner"
CONFIG_FILE="$RUNNER_VOLUME_DIR/.runner"

if [ -z "$(ls -A $RUNNER_VOLUME_DIR)" ]; then
  echo "Runner volume is empty. Copying data to volume..."
  cp -r $RUNNER_INSTALL_DIR/* $RUNNER_VOLUME_DIR/
fi

cd $RUNNER_VOLUME_DIR

sleep 100000000

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Runner is not configured. Configuring..."
  ./config.sh --unattended --replace --name ${RUNNER_NAME} --url https://github.com/${GITHUB_REPOSITORY} --token $RUNNER_TOKEN
else
  echo "Runner is already configured. Skipping configuration."
fi

./run.sh
