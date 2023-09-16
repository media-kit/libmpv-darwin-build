#!/bin/bash

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

cd ${SRC_DIR}

# cross build with meson
cp ${PROJECT_DIR}/scripts/mbedtls/meson.build ./meson.build
meson setup build_cross \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${OUTPUT_DIR}"
meson compile -C build_cross mbedtls

# manually create output
## create output layout
mkdir -p dist/{include,lib}
mkdir -p dist/include/{mbedtls,psa}
mkdir -p dist/lib/pkgconfig
## install headers
cp -R subprojects/mbedtls/include/mbedtls/*.h dist/include/mbedtls
cp -R subprojects/mbedtls/include/psa/*.h dist/include/psa
## install libs
find . -type f -name '*.dylib' -exec sh -c 'mv {} dist/lib' \;
## install pkgconfig file
cp ${PROJECT_DIR}/scripts/mbedtls/mbedtls.pc.in dist/lib/pkgconfig/mbedtls.pc
sed -i '' 's|${PREFIX}|'${OUTPUT_DIR}'|g' dist/lib/pkgconfig/mbedtls.pc

# manual install
mkdir -p "${OUTPUT_DIR}"
cp -R dist/* "${OUTPUT_DIR}"/
