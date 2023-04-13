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

        #
        # TODO: Disable everything by default, and enable only the `audio`
        # features. Do the same for the `video` variant.
        #

        # Manually enable selected protocols & networking support.
        '--enable-network',
        '--enable-protocol=async',
        '--enable-protocol=cache',
        '--enable-protocol=data',
        '--enable-protocol=ffrtmphttp',
        '--enable-protocol=file',
        '--enable-protocol=ftp',
        '--enable-protocol=hls',
        '--enable-protocol=http',
        '--enable-protocol=httpproxy',
        '--enable-protocol=https',
        '--enable-protocol=mmsh',
        '--enable-protocol=mmst',
        '--enable-protocol=pipe',
        '--enable-protocol=rtmp',
        '--enable-protocol=rtmps',
        '--enable-protocol=rtmpt',
        '--enable-protocol=rtmpts',
        '--enable-protocol=rtp',
        '--enable-protocol=sctp',
        '--enable-protocol=srtp',
        '--enable-protocol=subfile',
        '--enable-protocol=tcp',
        '--enable-protocol=tls',
        '--enable-protocol=udp',
        '--enable-protocol=udplite',
        '--enable-protocol=unix',
        '--enable-protocol=rist',
        '--enable-protocol=srt',
        '--enable-protocol=sftp',
        # Disable most features by default for finer selection later on.
        '--disable-iconv',
        '--disable-bzlib',
        '--disable-lzma',
        '--disable-sdl2',
        '--disable-schannel',
        '--disable-securetransport',
        '--disable-xlib',
        '--disable-d3d11va',
        '--disable-nvenc',
        '--disable-dxva2',
        '--disable-bsfs',
        '--disable-indevs',
        '--disable-outdevs',
        '--disable-bsfs',
        '--disable-muxers',
        '--disable-demuxers',
        '--disable-encoders',
        '--disable-decoders',
        '--disable-filters',
        '--disable-parsers',
        # Enable audio & image demuxers.
        '--enable-demuxer=image2',
        '--enable-demuxer=aac',
        '--enable-demuxer=ac3',
        '--enable-demuxer=aiff',
        '--enable-demuxer=ape',
        '--enable-demuxer=asf',
        '--enable-demuxer=au',
        '--enable-demuxer=avi',
        '--enable-demuxer=flac',
        '--enable-demuxer=flv',
        '--enable-demuxer=matroska',
        '--enable-demuxer=mov',
        '--enable-demuxer=m4v',
        '--enable-demuxer=mp3',
        '--enable-demuxer=mpc*',
        '--enable-demuxer=ogg',
        '--enable-demuxer=pcm*',
        '--enable-demuxer=rm',
        '--enable-demuxer=shorten',
        '--enable-demuxer=tak',
        '--enable-demuxer=tta',
        '--enable-demuxer=wav',
        '--enable-demuxer=wv',
        '--enable-demuxer=xwma',
        '--enable-demuxer=dsf',
        '--enable-demuxer=dts',
        '--enable-demuxer=truehd',
        # Enable audio & image decoders.
        '--enable-decoder=aac*',
        '--enable-decoder=ac3',
        '--enable-decoder=alac',
        '--enable-decoder=als',
        '--enable-decoder=ape',
        '--enable-decoder=atrac*',
        '--enable-decoder=eac3',
        '--enable-decoder=flac',
        '--enable-decoder=gsm*',
        '--enable-decoder=mp1*',
        '--enable-decoder=mp2*',
        '--enable-decoder=mp3*',
        '--enable-decoder=mpc*',
        '--enable-decoder=opus',
        '--enable-decoder=ra*',
        '--enable-decoder=ralf',
        '--enable-decoder=shorten',
        '--enable-decoder=tak',
        '--enable-decoder=tta',
        '--enable-decoder=vorbis',
        '--enable-decoder=wavpack',
        '--enable-decoder=wma*',
        '--enable-decoder=pcm*',
        '--enable-decoder=dsd*',
        '--enable-decoder=truehd',
        '--enable-decoder=mjpeg',
        '--enable-decoder=ljpeg',
        '--enable-decoder=jpegls',
        '--enable-decoder=jpeg2000',
        '--enable-decoder=png',
        '--enable-decoder=gif',
        '--enable-decoder=bmp',
        '--enable-decoder=tiff',
        '--enable-decoder=webp',
        '--enable-decoder=jpegls',
        # Parsers ?
        '--enable-parser=aac*',
        '--enable-parser=ac3',
        '--enable-parser=cook',
        '--enable-parser=dca',
        '--enable-parser=flac',
        '--enable-parser=gsm',
        '--enable-parser=mpegaudio',
        '--enable-parser=tak',
        '--enable-parser=vorbis',
        # Enable overlay & equalizer audio filters.
        '--enable-filter=overlay',
        '--enable-filter=equalizer',
        # Disable few more things.
        '--disable-doc',
        '--disable-cuda',
        '--disable-nvdec',
        '--disable-nvenc',
        '--disable-cuvid',
        '--disable-libuavs3d',
        '--disable-ffnvcodec',
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
