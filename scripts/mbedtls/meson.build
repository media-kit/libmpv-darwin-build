# https://mesonbuild.com/External-Project-module.html

project('mbedtls', 'c')

cmake = import('cmake')

options = cmake.subproject_options()
options.add_cmake_defines({
    'CMAKE_OSX_SYSROOT': meson.get_cross_property('sys_root'),
    'USE_STATIC_MBEDTLS_LIBRARY': false,
    'USE_SHARED_MBEDTLS_LIBRARY': true,
    'LINK_WITH_PTHREAD': true,
})

mbedtls = cmake.subproject('mbedtls',
    options: options,
)

mbedtls_dep = mbedtls.dependency('mbedtls')
meson.override_dependency('mbedtls', mbedtls_dep)
