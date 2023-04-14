#!/bin/sh

cd ${TOOLS_SOURCES_DIR}/pkg-config

cp ${PROJECT_DIR}/scripts/pkg-config/meson.build ./meson.build
meson setup build \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${TOOLS_PREFIX}"

meson compile -C build pkg-config

# manual install to preserve symlinks (meson install -C build)
mkdir -p "${TOOLS_PREFIX}"
cp -R build/dist"${TOOLS_PREFIX}"/* "${TOOLS_PREFIX}"/
