#!/bin/sh

cd ${SOURCES_DIR}/ffmpeg

patch -p1 <${PROJECT_DIR}/patches/ffmpeg-fix-ios-hdr-texture.patch

if [ "${VARIANT}" == "audio" ]; then
    cp ${PROJECT_DIR}/scripts/ffmpeg/audio/meson.build ./meson.build
elif [ "${VARIANT}" == "video" ]; then
    cp ${PROJECT_DIR}/scripts/ffmpeg/video/meson.build ./meson.build
fi

meson setup build \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${PREFIX}"

meson compile -C build ffmpeg

# manual install to preserve symlinks (meson install -C build)
mkdir -p "${PREFIX}"
cp -R build/dist"${PREFIX}"/* "${PREFIX}"/
