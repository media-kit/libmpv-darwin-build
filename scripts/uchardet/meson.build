# https://mesonbuild.com/External-Project-module.html

project('uchardet', 'c', 'cpp')

cmake = import('cmake')

options = cmake.subproject_options()
options.add_cmake_defines({
    'BUILD_STATIC': false,
})

uchardet = cmake.subproject('uchardet',
    options: options,
)

uchardet_dep = uchardet.dependency('libuchardet')
meson.override_dependency('uchardet', uchardet_dep)
