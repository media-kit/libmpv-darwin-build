#!/bin/sh

# check BINARY presence in \$TOOLS_PREFIX/bin
for BINARY in ${BINARIES}; do
    test -f ${TOOLS_PREFIX}/bin/$BINARY
done
