# https://mesonbuild.com/External-Project-module.html

project('libsrt', 'c', 'cpp')

mod = import('unstable-external_project')

# build binaries
c = meson.get_compiler('c')
cpp = meson.get_compiler('cpp')
pkg_config = find_program('pkg-config')

# build options
c_args = get_option('c_args')
cpp_args = get_option('cpp_args')
mbedtls = get_option('prefix').replace('libsrt', 'mbedtls')

options = [
    '--prefix=@PREFIX@',
    '--target-os=@0@'.format(host_machine.system()),
    '--arch=@0@'.format(host_machine.cpu_family()),
    '--cc=@0@'.format(''.join(c.cmd_array())),
    '--cxx=@0@'.format(''.join(cpp.cmd_array())),
    '--ld=@0@'.format(''.join(c.cmd_array())),
    '--pkg-config=@0@'.format(pkg_config.path()),
    '--enable-static=0',
    '--enable-shared=1',
    '--enable-apps=0',
    '--use-enclib=mbedtls',
    '--disable-test',
    '--MBEDTLS_PREFIX=' + mbedtls,
]

if meson.get_cross_property('subsystem') == 'ios'
    options += [
      '--cmake-prefix-path=@PREFIX@',
      '--CMAKE_IOS_SDK_ROOT=' + meson.get_cross_property('cmake_osx_sysroot'),
      '--MBEDTLS_LIBRARIES='+ mbedtls+ '/lib/',
      '--MBEDTLS_INCLUDE_DIRS=' + mbedtls + '/include/',
    ]
endif

p = mod.add_project('configure',
    configure_options: options,
    verbose: true,
)

libsrt_dep = p.dependency('libsrt')
mbedtls_dep = p.dependency('mbedtls')
meson.override_dependency('mbedtls', mbedtls_dep)
meson.override_dependency('libsrt', libsrt_dep)

