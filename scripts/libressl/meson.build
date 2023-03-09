# https://mesonbuild.com/External-Project-module.html

project('libressl', 'c')

mod = import('unstable-external_project')

p = mod.add_project('configure',
    configure_options : [
        '--prefix=@PREFIX@',
        '--disable-static',
        '--enable-shared',
        '--disable-dependency-tracking',
        '--disable-silent-rules',
    ],
    verbose: true,
)

libressl_dep = p.dependency('libressl')
meson.override_dependency('libressl', libressl_dep)
