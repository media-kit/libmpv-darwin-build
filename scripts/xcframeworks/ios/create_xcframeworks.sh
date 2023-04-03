#!/bin/sh

FRAMEWORKS_IOS_DIR="$1"
FRAMEWORKS_IOSSIMULATOR_DIR="$2"
XCFRAMEWORKS_DIR="$3"

find "${FRAMEWORKS_IOS_DIR}" -name "*.framework" -type d | while read FRAMEWORK_IOS; do
    FRAMEWORK_IOSSIMULATOR=$(echo "${FRAMEWORK_IOS}" | sed 's/ios/iossimulator'/g | sed 's/arm64/universal'/g)
    FRAMEWORK_NAME=$(basename "$FRAMEWORK_IOS" .framework)

    echo "${FRAMEWORK_NAME}"

    xcodebuild -create-xcframework \
        -framework "${FRAMEWORK_IOS}" \
        -framework "${FRAMEWORK_IOSSIMULATOR}" \
        -output "${XCFRAMEWORKS_DIR}/${FRAMEWORK_NAME}.xcframework"
done
