#!/bin/sh

if [ "${OS}" == "macos" ]; then
    sh "${PROJECT_DIR}/scripts/frameworks/macos/create_frameworks.sh" \
        "${LIBS_DIR}" \
        "${FRAMEWORKS_DIR}"
elif [ "${OS}" == "ios" ] || [ "${OS}" == "iossimulator" ]; then
    sh "${PROJECT_DIR}/scripts/frameworks/ios/create_frameworks.sh" \
        "${LIBS_DIR}" \
        "${FRAMEWORKS_DIR}"
fi
