#!/bin/sh

# see: MobileVLCKit cocoapods

LIBS_DIR="$1"
FRAMEWORKS_DIR="$2"

find "${LIBS_DIR}" -name "*.dylib" -type f | while read DYLIB; do
    echo "${DYLIB}"

    # create framework name: libavcodec.59.dylib -> Avcodec
    FRAMEWORK_NAME=$(basename $DYLIB .dylib | sed 's/\.[0-9]*$//' | sed 's/^lib//')
    FRAMEWORK_NAME="$(tr '[:lower:]' '[:upper:]' <<< ${FRAMEWORK_NAME:0:1})${FRAMEWORK_NAME:1}"

    # framework dir
    FRAMEWORK_DIR="${FRAMEWORKS_DIR}/${FRAMEWORK_NAME}.framework"

    # we get the min supported version from the arm64 version, because it is the
    # highest
    MIN_OS_VERSION=$(xcrun vtool -arch arm64 -show "${DYLIB}" | grep minos | cut -d ' ' -f6)

    # copy dylib
    mkdir -p "${FRAMEWORK_DIR}"
    cp "${DYLIB}" "${FRAMEWORK_DIR}/${FRAMEWORK_NAME}"

    # replace DYLIB var
    DYLIB="${FRAMEWORK_DIR}/${FRAMEWORK_NAME}"

    codesign --force -s - "${DYLIB}"

    # update dylib id
    NEW_ID="@rpath/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"
    install_name_tool \
        -id "${NEW_ID}" "${DYLIB}" \
        2> /dev/null

    # update dylib dep paths
    otool -l "${DYLIB}" |
        grep " name " |
        cut -d " " -f11 |
        tail -n +2 |
        grep "@rpath" |
        while read DEP; do
            DEP_NAME=$(basename $DEP .dylib | sed 's/\.[0-9]*$//' | sed 's/^lib//')
            DEP_NAME="$(tr '[:lower:]' '[:upper:]' <<< ${DEP_NAME:0:1})${DEP_NAME:1}"

            NEW_DEP="@rpath/${DEP_NAME}.framework/${DEP_NAME}"

            install_name_tool \
                -change "${DEP}" "${NEW_DEP}" \
                "${DYLIB}" \
                2>/dev/null
        done

    codesign --remove "${DYLIB}"

    # add Info.plist
    cp ./scripts/frameworks/ios/Info.plist "${FRAMEWORK_DIR}/"
    sed -i '' 's/${FRAMEWORK_NAME}/'${FRAMEWORK_NAME}'/g' "${FRAMEWORK_DIR}/Info.plist"
    sed -i '' 's/${MIN_OS_VERSION}/'${MIN_OS_VERSION}'/g' "${FRAMEWORK_DIR}/Info.plist"
    plutil -convert binary1 "${FRAMEWORK_DIR}/Info.plist"
done
