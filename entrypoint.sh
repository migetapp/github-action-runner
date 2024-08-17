#!/bin/bash

echo "alias docker=podman" >> ~/.bashrc
source ~/.bashrc
./config.sh --url https://github.com/${GITHUB_REPOSITORY} --token ${RUNNER_TOKEN} --unattended --replace
./run.sh
