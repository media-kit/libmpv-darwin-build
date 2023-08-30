#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

cd ${SRC_DIR}
meson setup build \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${OUTPUT_DIR}" \
    -Dbitdepths="['8', '16']" \
    -Denable_asm=false \
    -Denable_tools=false \
    -Denable_examples=false \
    -Denable_tests=false \
    -Denable_docs=false \
    -Dlogging=true \
    -Dtestdata_tests=false \
    -Dfuzzing_engine=none \
    -Dfuzzer_ldflags= \
    -Dstack_alignment=0 \
    -Dxxhash_muxer=auto \
    -Dtrim_dsp=if-release
meson compile -C build
meson install -C build
