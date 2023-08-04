#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

get_element() {
    str="$1"
    n="$2"

    i=1
    for word in $str; do
        if [ "$i" -eq "$n" ]; then
            echo "$word"
            return
        fi
        i=$((i + 1))
    done
}

DEP=$(get_element "$DEPS" 1)

find ${DEP} -name '*.dylib' -type f | while read DYLIB_ARCH; do
    DYLIB_ARCH1=$(echo ${DYLIB_ARCH} | sed -r "s|amd64|arm64|g")
    DYLIB_ARCH2=$(echo ${DYLIB_ARCH} | sed -r "s|arm64|amd64|g")
    DYLIB_NAME=$(basename ${DYLIB_ARCH1})
    DYLIB_OUTPUT=${OUTPUT_DIR}/${DYLIB_NAME}

    echo ${DYLIB_OUTPUT}

    lipo \
        -create "${DYLIB_ARCH1}" "${DYLIB_ARCH2}" \
        -output "${DYLIB_OUTPUT}"
done
