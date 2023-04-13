#!/bin/sh

rm -rf "${ARCHIVES_DIR}"
mkdir -p "${ARCHIVES_DIR}"

NAME=libmpv-${TYPE}-${VARIANT}-${VERSION}-${OS}-${ARCH}

cp -R "${FILES_DIR}" "${ARCHIVES_DIR}"/$NAME

cd "${ARCHIVES_DIR}"
tar -czvf $NAME.tar.gz $NAME
