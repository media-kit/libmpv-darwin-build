#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

find ${DEPS} -name '*.framework' -type d | while read FRAMEWORK; do
    FRAMEWORK_NAME=$(basename $FRAMEWORK .framework)

    echo ${FRAMEWORK_NAME}

    xcodebuild -create-xcframework \
        -framework ${FRAMEWORK} \
        -output ${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework
done
