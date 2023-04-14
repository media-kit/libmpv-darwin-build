#!/bin/sh

cd ${SOURCES_DIR}/uchardet

# cross build with meson
cp ${PROJECT_DIR}/scripts/uchardet/meson.build ./meson.build
meson setup build_cross \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${PREFIX}"
meson compile -C build_cross uchardet

# native build with cmake
cmake ./subprojects/uchardet \
    -B build_native \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DBUILD_STATIC=OFF
make -C build_native
DESTDIR=$PWD/dist make -C build_native install

# remove unecessary files
rm -rf "dist/${PREFIX}/bin"
rm -rf "dist/${PREFIX}/lib/cmake"
rm -rf "dist/${PREFIX}/share"

# get dylib id
DYLIB_FILE=$(find "dist${PREFIX}/lib" -type f -name '*.dylib')
DYLIB_ID=$(otool -l "$DYLIB_FILE" | grep ' name ' | cut -d ' ' -f 11 | head -n +1)

# replace native dylib by cross dylib & update id
cp 'build_cross/subprojects/uchardet/liblibuchardet.dylib' "$DYLIB_FILE"
install_name_tool -id "$DYLIB_ID" "$DYLIB_FILE"

# manual install to preserve symlinks
mkdir -p "${PREFIX}"
cp -R dist"${PREFIX}"/* "${PREFIX}"/
