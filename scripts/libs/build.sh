#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

if [ "${ARCH}" == "universal" ]; then
    sh ${PROJECT_DIR}/scripts/libs/build-universal.sh
else
    sh ${PROJECT_DIR}/scripts/libs/build-arch.sh
fi
