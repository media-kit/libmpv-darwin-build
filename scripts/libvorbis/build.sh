#!/bin/bash

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

cd ${SRC_DIR}

patch -p1 <${PROJECT_DIR}/patches/ltmain-target-passthrough.patch

# Fix building on modern macOS
sed -i '' 's/\-force_cpusubtype_ALL//g' configure

cp ${PROJECT_DIR}/scripts/libvorbis/meson.* .

meson setup build \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${OUTPUT_DIR}" |
    tee configure.log

meson compile -C build libvorbis
meson install -C build
