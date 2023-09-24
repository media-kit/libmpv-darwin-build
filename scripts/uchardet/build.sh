#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

cd ${SRC_DIR}

# cross build with meson
cp ${PROJECT_DIR}/scripts/uchardet/meson.build ./meson.build
meson setup build_cross \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${OUTPUT_DIR}"
meson compile -C build_cross uchardet

# TODO: don't build twice, see what's done for mbetls
# native build with cmake
cmake ./subprojects/uchardet \
    -B build_native \
    -DCMAKE_INSTALL_PREFIX="${OUTPUT_DIR}" \
    -DBUILD_STATIC=OFF
make -C build_native
DESTDIR=$PWD/dist make -C build_native install

# remove unecessary files
rm -rf "dist/${OUTPUT_DIR}/bin"
rm -rf "dist/${OUTPUT_DIR}/lib/cmake"
rm -rf "dist/${OUTPUT_DIR}/share"

# get dylib id
DYLIB_FILE=$(find "dist${OUTPUT_DIR}/lib" -type f -name '*.dylib')
DYLIB_ID=$(otool -l "$DYLIB_FILE" | grep ' name ' | cut -d ' ' -f 11 | head -n +1)

# replace native dylib by cross dylib & update id
cp 'build_cross/subprojects/uchardet/liblibuchardet.dylib' "$DYLIB_FILE"
install_name_tool -id "$DYLIB_ID" "$DYLIB_FILE"

# manual install to preserve symlinks
mkdir -p "${OUTPUT_DIR}"
cp -R dist"${OUTPUT_DIR}"/* "${OUTPUT_DIR}"/
