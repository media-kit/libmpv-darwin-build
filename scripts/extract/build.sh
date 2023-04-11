#!/bin/sh

mkdir -p ${TARGET_DIR}
find downloads -type f -name "${PKG_NAME}-*.tar.*" -exec \
    tar \
    -xvf {} \
    --strip-components 1 \
    -C ${TARGET_DIR} \
    \
    \; 2>&1
