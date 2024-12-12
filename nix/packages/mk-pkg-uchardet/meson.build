# https://mesonbuild.com/External-Project-module.html

project('uchardet', 'c', 'cpp')

cmake = import('cmake')

cpu = host_machine.cpu()
if cpu == 'amd64'
    arch = 'x86_64'
elif cpu == 'arm64'
    arch = 'arm64'
endif

options = cmake.subproject_options()
options.add_cmake_defines({
    'CMAKE_INSTALL_PREFIX': get_option('prefix'),
    'CMAKE_OSX_ARCHITECTURES': arch,
    'CMAKE_OSX_SYSROOT': meson.get_cross_property('cmake_osx_sysroot'),
    'CMAKE_BUILD_TYPE': 'Release',
    'CMAKE_C_COMPILER_WORKS': true,
    'CMAKE_CXX_COMPILER_WORKS': true,
    'BUILD_STATIC': false,
    'BUILD_BINARY': false,
})

uchardet = cmake.subproject('uchardet',
    options: options,
)

uchardet_dep = uchardet.dependency('libuchardet')
meson.override_dependency('uchardet', uchardet_dep)
