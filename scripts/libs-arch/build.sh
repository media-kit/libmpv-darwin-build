#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

# copy dylibs except '*-subset.*.dylib'
for DEP in ${DEPS}; do
    find ${DEP}/lib \
        -type f -name '*.dylib' \
        ! -name '*-subset.*.dylib' \
        -exec \
        cp "{}" "${OUTPUT_DIR}" \
        \;
done

# libfoo.100.99.88.dylib -> libfoo.100.dylib
find ${OUTPUT_DIR} -type f -name '*.dylib' -exec \
    sh -c 'mv "{}" $(echo "{}" | sed -r "s|([0-9]+)(\.[0-9]+)*|\1|g")' \
    \;

# rename libmpv file
mv ${OUTPUT_DIR}/libmpv.*.dylib ${OUTPUT_DIR}/libmpv.dylib
install_name_tool -id @rpath/libmpv.dylib ${OUTPUT_DIR}/libmpv.dylib

# fix deps paths
${PROJECT_DIR}/scripts/libs-arch/relink-dylibs.sh ${PROJECT_DIR} @rpath ${OUTPUT_DIR}

# remove signatures
codesign --remove ${OUTPUT_DIR}/*.dylib

if [ "${OS}" == "iossimulator" ] && [ "${ARCH}" == "arm64" ]; then
    sh ${PROJECT_DIR}/scripts/libs-arch/fix-iossimulator-arm64.sh ${OUTPUT_DIR}
fi
