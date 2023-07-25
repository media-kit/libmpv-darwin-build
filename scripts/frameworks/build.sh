#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

if [ "${OS}" == "macos" ]; then
    sh ${PROJECT_DIR}/scripts/frameworks/macos/create_frameworks.sh
elif [ "${OS}" == "ios" ] || [ "${OS}" == "iossimulator" ]; then
    sh ${PROJECT_DIR}/scripts/frameworks/ios/create_frameworks.sh
fi
