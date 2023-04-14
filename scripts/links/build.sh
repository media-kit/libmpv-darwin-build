#!/bin/sh

mkdir -p ${TOOLS_PREFIX}/bin

# check BINARY presence in PATH
for BINARY in ${BINARIES}; do
    [ -z $(which $BINARY) ] &&
        echo $BINARY not found in \$PATH &&
        false || true
done

# sym link BINARY
for BINARY in ${BINARIES}; do
    [ ! -h ${TOOLS_PREFIX}/bin/$BINARY ] &&
        ln -s $(which $BINARY) ${TOOLS_PREFIX}/bin/$BINARY ||
        true
done
