#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

cd ${SRC_DIR}
meson setup build \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${OUTPUT_DIR}" \
    -Ddeprecated=false \
    -Ddocs=false \
    -Dbin=false \
    -Dtests=false \
    -Dfuzzer_ldflags=
meson compile -C build
meson install -C build
