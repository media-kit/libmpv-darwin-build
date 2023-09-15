#!/bin/bash

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

cd ${SRC_DIR}

cp ${PROJECT_DIR}/scripts/libogg/meson.* .

meson setup build \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${OUTPUT_DIR}" |
    tee configure.log

meson compile -C build libogg
meson install -C build
