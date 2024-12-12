# https://mesonbuild.com/External-Project-module.html

project('mbedtls', 'c')

cmake = import('cmake')

cpu = host_machine.cpu()
if cpu == 'amd64'
    arch = 'x86_64'
elif cpu == 'arm64'
    arch = 'arm64'
endif

options = cmake.subproject_options()
options.add_cmake_defines({
    'CMAKE_OSX_ARCHITECTURES': arch,
    'CMAKE_OSX_SYSROOT': meson.get_cross_property('cmake_osx_sysroot'),
    'CMAKE_C_COMPILER_WORKS': true,
    'CMAKE_CXX_COMPILER_WORKS': true,
    'USE_STATIC_MBEDTLS_LIBRARY': false,
    'USE_SHARED_MBEDTLS_LIBRARY': true,
    'LINK_WITH_PTHREAD': true,
})

mbedtls = cmake.subproject('mbedtls',
    options: options,
)

mbedtls_dep = mbedtls.dependency('mbedtls')
meson.override_dependency('mbedtls', mbedtls_dep)
