# https://mesonbuild.com/External-Project-module.html

project('ffmpeg', 'c', 'cpp', 'objc')

mod = import('unstable-external_project')

# build binaries
c = meson.get_compiler('c')
cpp = meson.get_compiler('cpp')
objc = meson.get_compiler('objc')
nm = find_program('nm')
ar = find_program('ar')
strip = find_program('strip')
pkg_config = find_program('pkg-config')

# build options
c_args = get_option('c_args')
cpp_args = get_option('cpp_args')
objc_args = get_option('objc_args')
c_link_args = get_option('c_link_args')

# parameters
variant = get_option('variant')
flavor = get_option('flavor')

# options
disable_all_options = [
    '--disable-autodetect',
    '--disable-all',
    '--disable-x86asm',
    '--disable-runtime-cpudetect',
    '--disable-debug',
    '--disable-stripping',
    '--disable-optimizations',
    '--disable-static',
    '--disable-shared',
    '--disable-pthreads',
    '--disable-safe-bitstream-reader',
]

common_options = [
    '--prefix=@PREFIX@',
    '--enable-small', # reduce libs size
    '--enable-optimizations',
    '--enable-shared',
    '--enable-network',
    '--enable-pthreads',
    '--enable-pic',
    '--enable-mbedtls', # tls support (mbedtls)
    '--enable-version3',
    '--enable-safe-bitstream-reader',
    '--enable-stripping',
    '--enable-avcodec',
    '--enable-avformat',
    '--enable-swresample',
    '--enable-swscale',
    '--enable-avfilter',

    '--enable-decoder=mjpeg',
    '--enable-decoder=ljpeg',
    '--enable-decoder=jpegls',
    '--enable-decoder=jpeg2000',
    '--enable-decoder=png',
    '--enable-decoder=gif',
    '--enable-decoder=bmp',
    '--enable-decoder=tiff',
    '--enable-decoder=webp',

    '--enable-encoder=mjpeg',
    '--enable-encoder=ljpeg',
    '--enable-encoder=jpegls',
    '--enable-encoder=jpeg2000',
    '--enable-encoder=png',

    # '--enable-gpl', # uncomment it to include GPL code
    # '--enable-nonfree', # uncomment it to include unredistributable code
]

audio_common_options = [
    '--enable-zlib', # rasc support
    '--enable-audiotoolbox',
]

video_common_options = [
    '--enable-neon', # improve hevc (h265) support on arm
    '--enable-libxml2', # dash support
    '--enable-videotoolbox',
    '--enable-libdav1d', # av1 support
]

# https://github.com/media-kit/libmpv-android-audio-build/blob/260666c0fef8c154971b5faf3f78da27c2bf2c40/buildscripts/flavors/default.sh
audio_default_options = [
    # decoders
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
    '--enable-decoder=dca', # required by dts

    # parsers   
    '--enable-parser=aac*',
    '--enable-parser=ac3',
    '--enable-parser=cook',
    '--enable-parser=dca',
    '--enable-parser=flac',
    '--enable-parser=gsm',
    '--enable-parser=mpegaudio',
    '--enable-parser=tak',
    '--enable-parser=vorbis',

    # demuxers
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

    # protocols
    '--enable-protocol=async',
    '--enable-protocol=cache',
    '--enable-protocol=crypto',
    '--enable-protocol=data',
    '--enable-protocol=ffrtmphttp',
    '--enable-protocol=file',
    '--enable-protocol=ftp',
    '--enable-protocol=hls',
    '--enable-protocol=http',
    '--enable-protocol=httpproxy',
    '--enable-protocol=https',
    '--enable-protocol=pipe',
    '--enable-protocol=rtmp',
    '--enable-protocol=rtmps',
    '--enable-protocol=rtmpt',
    '--enable-protocol=rtmpts',
    '--enable-protocol=rtp',
    '--enable-protocol=subfile',
    '--enable-protocol=tcp',
    '--enable-protocol=tls',
    # '--enable-protocol=srt', # WARNING: Option --enable-protocol=srt did not match anything

    # filters
    '--enable-filter=overlay',
    '--enable-filter=equalizer',
]

# https://github.com/media-kit/libmpv-android-video-build/blob/7353af784df9bab3256acd8d90f208024d16ab96/buildscripts/flavors/default.sh
video_default_options = [
    # decoders
    '--enable-decoder=flv',
    '--enable-decoder=h263',
    '--enable-decoder=h263i',
    '--enable-decoder=h263p',
    '--enable-decoder=h264', # h264*
    '--enable-decoder=mpeg1video',
    '--enable-decoder=mpeg2video', # mpeg2*
    '--enable-decoder=mpeg4', # mpeg4*
    '--enable-decoder=vp6',
    '--enable-decoder=vp6a',
    '--enable-decoder=vp6f',
    '--enable-decoder=vp8', # vp8*
    '--enable-decoder=vp9', # vp9*
    '--enable-decoder=hevc', # hevc*
    '--enable-decoder=av1', # av1*
    '--enable-decoder=libdav1d',
    '--enable-decoder=theora',
    '--enable-decoder=msmpeg4v1', # msmpeg*
    '--enable-decoder=msmpeg4v2', # msmpeg*
    '--enable-decoder=msmpeg4v3', # msmpeg*
    '--enable-decoder=mjpeg',
    '--enable-decoder=wmv1', # wmv*
    '--enable-decoder=wmv2', # wmv*
    '--enable-decoder=wmv3', # wmv*
    '--enable-decoder=wmv3image', # wmv*

    '--enable-decoder=ssa',
    '--enable-decoder=ass',
    '--enable-decoder=dvbsub',
    '--enable-decoder=dvdsub',
    '--enable-decoder=srt',
    '--enable-decoder=stl',
    '--enable-decoder=subrip',
    '--enable-decoder=subviewer',
    '--enable-decoder=subviewer1',
    '--enable-decoder=text',
    '--enable-decoder=vplayer',
    '--enable-decoder=webvtt',
    '--enable-decoder=movtext',

    # parsers
    '--enable-parser=h263',
    '--enable-parser=h264',
    '--enable-parser=hevc',
    # '--enable-parser=mpeg4', # WARNING: Option --enable-parser=mpeg4 did not match anything
    '--enable-parser=mpeg4video',
    '--enable-parser=mpegvideo',

    # demuxers
    '--enable-demuxer=concat',
    '--enable-demuxer=data',
    '--enable-demuxer=flv',
    '--enable-demuxer=hls',
    # '--enable-demuxer=latm', # WARNING: Option --enable-demuxer=latm did not match anything
    '--enable-demuxer=live_flv',
    '--enable-demuxer=loas',
    '--enable-demuxer=m4v',
    '--enable-demuxer=mov',
    '--enable-demuxer=mpegps',
    '--enable-demuxer=mpegts',
    '--enable-demuxer=mpegvideo',
    '--enable-demuxer=hevc',
    '--enable-demuxer=rtsp',
    # '--enable-demuxer=mpeg4', # WARNING: Option --enable-demuxer=mpeg4 did not match anything
    '--enable-demuxer=mjpeg',
    '--enable-demuxer=avi',
    '--enable-demuxer=av1',
    '--enable-demuxer=matroska',
    '--enable-demuxer=dash', # --enable-libxml2 required
    '--enable-demuxer=webm_dash_manifest',

    '--enable-demuxer=ass',
    '--enable-demuxer=srt',
    '--enable-demuxer=stl',
    '--enable-demuxer=webvtt',
    '--enable-demuxer=subviewer',
    '--enable-demuxer=subviewer1',
    '--enable-demuxer=vplayer',

    # hwaccels
    '--enable-hwaccel=h263_videotoolbox',
    '--enable-hwaccel=h264_videotoolbox',
    '--enable-hwaccel=hevc_videotoolbox',
    '--enable-hwaccel=mpeg1_videotoolbox',
    '--enable-hwaccel=mpeg2_videotoolbox',
    '--enable-hwaccel=mpeg4_videotoolbox',
    '--enable-hwaccel=vp9_videotoolbox',
]

audio_full_options = [
    '--enable-decoders',
    '--enable-hwaccels',
    '--enable-parsers',
    '--enable-demuxers',
    '--enable-protocols',
    '--enable-bsfs',

    # filters
    '--enable-filter=overlay',
    '--enable-filter=equalizer',

    # TODO: `media_kit` checks the presence of the h264 decoder to determine if
    # `ffmpeg` is an audio or video variant, so we disable it for the audio
    # variant.
    # Ideally, we should only enable the audio decoders…
    '--disable-decoder=h264',
]

video_full_options = [
    '--enable-decoder=h264',
]

audio_encodersgpl_options = [
    '--enable-encoders',
    '--enable-muxers',
    '--enable-filters',
    '--enable-libvorbis',
    # TODO: If audio_encoders is going to exist as its own package, be smarter about what encoders to include
]

video_encodersgpl_options = [
    '--enable-libvpx',
    '--enable-libx264',
    '--enable-gpl'
]

# disable all option
options = disable_all_options

# common
options += common_options
options += audio_common_options
if variant == 'video'
    options += video_common_options
endif

# components
if flavor == 'default'
    options += audio_default_options
    if variant == 'video'
        options += video_default_options
    endif
elif flavor == 'full'
    options += audio_full_options
    if variant == 'video'
        options += video_full_options
    endif
elif flavor == 'encodersgpl'
    options += audio_full_options
    options += audio_encodersgpl_options
    if variant == 'video'
        options += video_full_options
        options += video_encodersgpl_options
    endif
endif

p = mod.add_project('configure',
    configure_options : options,
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

libavfilter_dep = p.dependency('avfilter')
libswscale_dep = p.dependency('swscale')
libavcodec_dep = p.dependency('avcodec')
libavformat_dep = p.dependency('avformat')
libavutil_dep = p.dependency('avutil')
libswresample_dep = p.dependency('swresample')

meson.override_dependency('libavfilter', libavfilter_dep)
meson.override_dependency('libswscale', libswscale_dep)
meson.override_dependency('libavcodec', libavcodec_dep)
meson.override_dependency('libavformat', libavformat_dep)
meson.override_dependency('libavutil', libavutil_dep)
meson.override_dependency('libswresample', libswresample_dep)
