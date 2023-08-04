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

DEP1=$(get_element "$DEPS" 1)
DEP2=$(get_element "$DEPS" 2)

find ${DEP1} -name "*.framework" -type d | while read FRAMEWORK; do
    FRAMEWORK_NAME=$(basename "$FRAMEWORK" .framework)
    FRAMEWORK_OS1=${DEP1}/${FRAMEWORK_NAME}.framework
    FRAMEWORK_OS2=${DEP2}/${FRAMEWORK_NAME}.framework
    FRAMEWORK_OUTPUT=${OUTPUT_DIR}/${FRAMEWORK_NAME}.xcframework

    echo ${FRAMEWORK_NAME}

    xcodebuild -create-xcframework \
        -framework ${FRAMEWORK_OS1} \
        -framework ${FRAMEWORK_OS2} \
        -output ${FRAMEWORK_OUTPUT}
done
