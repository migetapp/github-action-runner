#!/bin/bash

./config.sh --name ${RUNNER_NAME} --url https://github.com/${GITHUB_REPOSITORY} --token ${RUNNER_TOKEN} --unattended --replace
./run.sh
