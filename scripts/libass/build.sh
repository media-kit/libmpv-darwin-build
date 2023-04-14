#!/bin/sh

cd ${SOURCES_DIR}/libass

cp ${PROJECT_DIR}/scripts/libass/meson.build ./meson.build
meson setup build \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${PREFIX}"

meson compile -C build libass

# manual install to preserve symlinks (meson install -C build)
mkdir -p "${PREFIX}"
cp -R build/dist"${PREFIX}"/* "${PREFIX}"/
