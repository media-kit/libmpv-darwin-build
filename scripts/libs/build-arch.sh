#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

# copy dylibs
for DEP in ${DEPS}; do
    find ${DEP} \
        -type f -name '*.dylib' \
        -exec \
        cp "{}" "${OUTPUT_DIR}" \
        \;
done
