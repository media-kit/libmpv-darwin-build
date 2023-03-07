# https://mesonbuild.com/External-Project-module.html

project('libass', 'c')

mod = import('unstable-external_project')

p = mod.add_project('configure',
    configure_options : [
        '--prefix=@PREFIX@',
        '--disable-static',
        '--enable-fast-install',
        '--disable-dependency-tracking',
        '--disable-test',
        '--disable-compare',
        '--disable-profile',
        '--disable-fuzz',
        '--disable-fontconfig',
        '--disable-directwrite',
        '--enable-coretext',
        '--disable-libunibreak',
        '--disable-require-system-font-provider',
        '--disable-asm',
        '--disable-large-tiles',
        '--with-pic',
        '--with-aix-soname=aix',
        '--without-gnu-ld',
    ],
    verbose: true,
)

libass_dep = p.dependency('libass')
meson.override_dependency('libass', libass_dep)
