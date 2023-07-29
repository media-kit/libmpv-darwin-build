#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

cd ${SRC_DIR}

patch -p1 <${PROJECT_DIR}/patches/ffmpeg-fix-ios-hdr-texture.patch

cp ${PROJECT_DIR}/scripts/ffmpeg/meson.* .

meson setup build \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${OUTPUT_DIR}" \
    -Dvariant=${VARIANT} \
    -Dflavor=${FLAVOR}

meson compile -C build ffmpeg

# manual install to preserve symlinks (meson install -C build)
mkdir -p "${OUTPUT_DIR}"
cp -R build/dist"${OUTPUT_DIR}"/* "${OUTPUT_DIR}"/
