#!/bin/bash

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

cd ${SRC_DIR}

# Extract c, c_args
export CC="$(python3 -c "$(grep "^c" ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini); print(' '.join(c + c_args))")"

make clean
make SHARED=1 no_test
make SHARED=1 DESTDIR="${OUTPUT_DIR}" install

mkdir -p "${OUTPUT_DIR}/lib/pkgconfig"
PC="${OUTPUT_DIR}/lib/pkgconfig/mbedtls.pc"
echo "prefix=\"${OUTPUT_DIR}\"" > "${PC}"
echo "exec_prefix=\${prefix}" >> "${PC}"
echo "includedir=\"\${prefix}/include\"" >> "${PC}"
echo "libdir=\"\${prefix}/lib\"" >> "${PC}"
echo >> "${PC}"
echo "Name: mbedtls" >> "${PC}"
echo "Description: cryptographic library" >> "${PC}"
echo "Version: unknown" >> "${PC}"
echo "Libs: -L\"\${libdir}\" -lmbedtls -lmbedcrypto -lmbedx509" >> "${PC}"
#echo Libs.private: -lm -framework ApplicationServices
echo "Cflags: -I\"\${includedir}\"" >> "${PC}"
