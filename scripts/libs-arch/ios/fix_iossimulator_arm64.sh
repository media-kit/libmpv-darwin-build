#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

# The Apple sdk for the arm64 simulator produces dylib whose platform in the
# headers is `IOS` and not `IOSSIMULATOR`. This is wrong.
# So, this script replaces the platform header with `IOSSIMULATOR`.
# See: https://bogo.wtf/arm64-to-sim-dylibs.html

LIBS_DIR=$1

ARCH=arm64
IOSSIMULATOR=7

find "${LIBS_DIR}" -type f | while read DYLIB; do
    echo "${DYLIB}"

    PLATFORM=$IOSSIMULATOR
    MINOS=$(xcrun vtool -arch arm64 -show "${DYLIB}" | grep minos | cut -d ' ' -f6)
    SDK=$(xcrun vtool -arch arm64 -show "${DYLIB}" | grep sdk | cut -d ' ' -f8)

    xcrun vtool \
        -arch $ARCH \
        -set-build-version $IOSSIMULATOR $MINOS $SDK \
        -replace \
        -output "${DYLIB}" \
        "${DYLIB}"
done
