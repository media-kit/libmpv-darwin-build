#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

mkdir -p ${OUTPUT_DIR}/bin

# check BINARY presence in PATH
for BINARY in ${BINARIES}; do
    [ -z $(which $BINARY) ] &&
        echo $BINARY not found in \$PATH &&
        false || true
done

# sym link BINARY
for BINARY in ${BINARIES}; do
    [ ! -h ${OUTPUT_DIR}/bin/$BINARY ] &&
        ln -s $(which $BINARY) ${OUTPUT_DIR}/bin/$BINARY ||
        true
done
