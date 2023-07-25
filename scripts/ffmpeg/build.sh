#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

cd ${SRC_DIR}

patch -p1 <${PROJECT_DIR}/patches/ffmpeg-fix-ios-hdr-texture.patch

if [ "${VARIANT}" == "audio" ]; then
    cp ${PROJECT_DIR}/scripts/ffmpeg/audio/meson.build ./meson.build
elif [ "${VARIANT}" == "video" ]; then
    cp ${PROJECT_DIR}/scripts/ffmpeg/video/meson.build ./meson.build
fi

meson setup build \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${OUTPUT_DIR}"

meson compile -C build ffmpeg

# manual install to preserve symlinks (meson install -C build)
mkdir -p "${OUTPUT_DIR}"
cp -R build/dist"${OUTPUT_DIR}"/* "${OUTPUT_DIR}"/
