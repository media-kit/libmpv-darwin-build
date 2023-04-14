#!/bin/sh

cd ${SOURCES_DIR}/harfbuzz
meson setup build \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${PREFIX}" \
    -Dglib=disabled \
    -Dgobject=disabled \
    -Dcairo=disabled \
    -Dchafa=disabled \
    -Dicu=disabled \
    -Dgraphite=disabled \
    -Dgraphite2=disabled \
    -Dfreetype=disabled \
    -Dgdi=disabled \
    -Ddirectwrite=disabled \
    -Dcoretext=enabled \
    -Dtests=disabled \
    -Dintrospection=disabled \
    -Ddocs=disabled \
    -Dbenchmark=disabled \
    -Dicu_builtin=false \
    -Dexperimental_api=false \
    -Dragel_subproject=false \
    -Dfuzzer_ldflags=
meson compile -C build
meson install -C build
