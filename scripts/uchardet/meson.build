# https://mesonbuild.com/External-Project-module.html

project('uchardet', 'c', 'cpp')

cmake = import('cmake')

options = cmake.subproject_options()
options.add_cmake_defines({
    'CMAKE_OSX_SYSROOT': meson.get_cross_property('sys_root'),
    'BUILD_STATIC': false,
})

uchardet = cmake.subproject('uchardet',
    options: options,
)

uchardet_dep = uchardet.dependency('libuchardet')
meson.override_dependency('uchardet', uchardet_dep)
