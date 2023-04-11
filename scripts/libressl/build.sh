#!/bin/sh

cd ${SOURCES_DIR}/libressl

cp ${PROJECT_DIR}/scripts/libressl/meson.build ./meson.build
meson setup build \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${PREFIX}"

meson compile -C build libressl

# fix file permissions
chmod 755 build/dist"${PREFIX}"/lib/*

# manual install to preserve symlinks (meson install -C build)
mkdir -p "${PREFIX}"
cp -R build/dist"${PREFIX}"/* "${PREFIX}"/
