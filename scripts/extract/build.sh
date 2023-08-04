#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

mkdir -p ${TARGET_DIR}
tar \
    -xvf ${ARCHIVE_FILE} \
    --strip-components 1 \
    -C ${TARGET_DIR}
