# https://mesonbuild.com/External-Project-module.html

project('libogg', 'c')

mod = import('unstable-external_project')

p = mod.add_project('configure',
    configure_options : [
        '--prefix=@PREFIX@',
        '--disable-static',
        '--enable-shared',
    ],
    verbose: true,
)

libogg_dep = p.dependency('libogg')
meson.override_dependency('libogg', libogg_dep)
