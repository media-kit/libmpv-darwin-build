#!/bin/sh

mkdir -p "${LIBS_UNIVERSAL_DIR}"

find "${LIBS_ARCH1_DIR}" -name "*.dylib" -type f | while read DYLIB_ARCH1; do
    DYLIB_ARCH2=$(echo "${DYLIB_ARCH1}" | sed -r "s|${ARCH1}|${ARCH2}|g")
    DYLIB_UNIVERSAL=$(echo "${DYLIB_ARCH1}" | sed -r "s|${ARCH1}|universal|g")

    lipo \
        -create "${DYLIB_ARCH1}" "${DYLIB_ARCH2}" \
        -output "${DYLIB_UNIVERSAL}"
done
