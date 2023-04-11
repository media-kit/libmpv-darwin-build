#!/bin/sh

rm -rf "${LIBS_DIR}"
mkdir -p "${LIBS_DIR}"

# copy dylibs except '*-subset.*.dylib'
find "${PREFIX}/lib" \
    -type f -name '*.dylib' \
    ! -name '*-subset.*.dylib' \
    -exec \
    cp "{}" "${LIBS_DIR}" \
    \;

# libfoo.100.99.88.dylib -> libfoo.100.dylib
find ${LIBS_DIR} -type f -name '*.dylib' -exec \
    sh -c 'mv "{}" $(echo "{}" | sed -r "s|([0-9]+)(\.[0-9]+)*|\1|g")' \
    \;

mv "${LIBS_DIR}"/libmpv.*.dylib "${LIBS_DIR}/libmpv.dylib"
install_name_tool -id @rpath/libmpv.dylib "${LIBS_DIR}/libmpv.dylib"

./scripts/libs/relink_dylibs.sh "${PREFIX}/lib" "${LIBS_DIR}"

codesign --remove "${LIBS_DIR}"/*.dylib

if [ "${OS}" == "iossimulator" ] && [ "${ARCH}" == "arm64" ]; then
    sh "${PROJECT_DIR}/scripts/libs/ios/fix_iossimulator_arm64.sh" "${LIBS_DIR}"
fi
