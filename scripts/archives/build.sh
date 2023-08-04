#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

cd ${SRC_DIR}

NAME=$(basename ${OUTPUT_FILE} .tar.gz)

cp -R ${DEPS} ${NAME}
tar -czvf ${NAME}.tar.gz ${NAME}
