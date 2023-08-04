# https://mesonbuild.com/External-Project-module.html

project('libxml2', 'c')

mod = import('unstable-external_project')

p = mod.add_project('configure',
    configure_options : [
        '--prefix=@PREFIX@',
        '--disable-static',
        '--enable-shared',
        '--disable-dependency-tracking',
        '--disable-silent-rules',
        '--without-python'
    ],
    verbose: true,
)

libxml2_dep = p.dependency('libxml2')
meson.override_dependency('libxml2', libxml2_dep)
