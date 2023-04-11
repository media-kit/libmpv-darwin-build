#!/bin/sh

cd ${SOURCES_DIR}/freetype
meson setup build \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${PREFIX}" \
    -Dbrotli=disabled \
    -Dbzip2=disabled \
    -Dharfbuzz=enabled \
    -Dmmap=disabled \
    -Dpng=disabled \
    -Dtests=disabled \
    -Dzlib=disabled
meson compile -C build
meson install -C build
