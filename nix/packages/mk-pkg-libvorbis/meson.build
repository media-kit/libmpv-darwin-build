# https://mesonbuild.com/External-Project-module.html

project('libvorbis', 'c')

mod = import('unstable-external_project')

p = mod.add_project('configure',
    configure_options : [
        '--prefix=@PREFIX@',
        '--disable-static',
        '--enable-shared',
        '--disable-tests'
    ],
    verbose: true,
)

libvorbis_dep = p.dependency('libvorbis')
meson.override_dependency('libvorbis', libvorbis_dep)
