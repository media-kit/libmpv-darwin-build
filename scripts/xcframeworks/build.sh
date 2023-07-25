#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

if [ "${OS}" == "ios" ]; then
    sh ${PROJECT_DIR}/scripts/xcframeworks/build-ios.sh
else
    sh ${PROJECT_DIR}/scripts/xcframeworks/build-generic.sh
fi
