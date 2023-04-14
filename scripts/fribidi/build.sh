#!/bin/sh

cd ${SOURCES_DIR}/fribidi
meson setup build \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${PREFIX}" \
    -Ddeprecated=false \
    -Ddocs=false \
    -Dbin=false \
    -Dtests=false \
    -Dfuzzer_ldflags=
meson compile -C build
meson install -C build
