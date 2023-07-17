# https://mesonbuild.com/External-Project-module.html

project('ffmpeg', 'c', 'cpp', 'objc')

mod = import('unstable-external_project')

# binaries
c = meson.get_compiler('c')
cpp = meson.get_compiler('cpp')
objc = meson.get_compiler('objc')
nm = find_program('nm')
ar = find_program('ar')
strip = find_program('strip')
pkg_config = find_program('pkgconfig')

# options
c_args = get_option('c_args')
cpp_args = get_option('cpp_args')
objc_args = get_option('objc_args')
c_link_args = get_option('c_link_args')

p = mod.add_project('configure',
    configure_options : [
        '--prefix=@PREFIX@',
        '--disable-static',
        '--enable-shared',
        # '--enable-gpl', # uncomment it to include GPL code
        # '--enable-nonfree', # uncomment it to include unredistributable code
        '--disable-lzma',
        '--disable-securetransport',
        '--disable-sdl2',
        '--disable-debug',
        '--disable-programs',
        '--disable-doc',
        '--disable-avdevice',
        '--disable-postproc',
        '--disable-x86asm',
        '--disable-xlib',
        '--disable-libxcb',
        '--disable-libxcb-shm',
        '--disable-libxcb-xfixes',
        '--disable-libxcb-shape',
        '--enable-libtls', # libressl (https support)
        '--enable-videotoolbox',
        '--enable-neon',
        '--enable-pic',
        '--disable-filter=yadif_videotoolbox',
    ],
    cross_configure_options: [
        '--enable-cross-compile',
        '--target-os=@0@'.format(host_machine.system()),
        '--arch=@0@'.format(host_machine.cpu_family()),

        '--nm=@0@'.format(nm.path()),
        '--ar=@0@'.format(ar.path()),
        '--as=@0@'.format(''.join(c.cmd_array())),
        '--strip=@0@'.format(strip.path()),
        '--cc=@0@'.format(''.join(c.cmd_array())),
        '--cxx=@0@'.format(''.join(cpp.cmd_array())),
        '--objcc=@0@'.format(''.join(objc.cmd_array())),
        '--ld=@0@'.format(''.join(c.cmd_array())),
        '--pkg-config=@0@'.format(pkg_config.path()),

        '--host-cc=@0@'.format(''.join(c.cmd_array())),
        '--host-ld=@0@'.format(''.join(c.cmd_array())),

        '--extra-cflags=@0@'.format(' '.join(c_args)),
        '--extra-cxxflags=@0@'.format(' '.join(cpp_args)),
        '--extra-objcflags=@0@'.format(' '.join(objc_args)),
        '--extra-ldflags=@0@'.format(' '.join(c_link_args)),
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
