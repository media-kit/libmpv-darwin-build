# https://mesonbuild.com/External-Project-module.html

project('ffmpeg', 'c')

mod = import('unstable-external_project')

p = mod.add_project('configure',
    configure_options : [
        '--prefix=@PREFIX@',
        '--disable-lzma',
        '--enable-securetransport',
        '--disable-sdl2',
        '--disable-debug',
        '--disable-programs',
        '--disable-doc',
        '--disable-avdevice',
        '--disable-postproc',
        '--enable-pic',
        '--disable-static',
        '--enable-shared',
        '--disable-x86asm',
        '--disable-xlib',
        '--disable-libxcb',
        '--disable-libxcb-shm',
        '--disable-libxcb-xfixes',
        '--disable-libxcb-shape',
        '--enable-videotoolbox',
        '--disable-asm', # FIXME: fix assembly support
        # '--enable-neon',
    ],
    cross_configure_options: [
        '--enable-cross-compile',
        '--target-os=@0@'.format(host_machine.system()),
        '--arch=@0@'.format(host_machine.cpu_family()),
    ],
    verbose: true,
)

libavfilter_dep = p.dependency('libavfilter')
libswscale_dep = p.dependency('libswscale')
libavcodec_dep = p.dependency('libavcodec')
libavformat_dep = p.dependency('libavformat')
libswresample_dep = p.dependency('libswresample')

meson.override_dependency('libavfilter', libavfilter_dep)
meson.override_dependency('libswscale', libswscale_dep)
meson.override_dependency('libavcodec', libavcodec_dep)
meson.override_dependency('libavformat', libavformat_dep)
meson.override_dependency('libswresample', libswresample_dep)
