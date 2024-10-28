{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix { },
  variant ? import ../../utils/default/variant.nix,
}:

let
  name = "mpv";
  packageLock = (import ../../../packages.lock.nix).${name};
  inherit (packageLock) version;

  variants = import ../../utils/constants/variants.nix;
  oses = import ../../utils/constants/oses.nix;
  callPackage = pkgs.lib.callPackageWith {
    inherit
      pkgs
      os
      arch
      variant
      ;
  };
  nativeFile = callPackage ../../utils/native-file/default.nix { };
  crossFile = callPackage ../../utils/cross-file/default.nix { };
  xctoolchainLipo = callPackage ../../utils/xctoolchain/lipo.nix { };
  ffmpeg = callPackage ../mk-pkg-ffmpeg/default.nix { };
  uchardet = callPackage ../mk-pkg-uchardet/default.nix { };
  libass = callPackage ../mk-pkg-libass/default.nix { };

  nativeBuildInputs = [
    pkgs.meson
    pkgs.ninja
    pkgs.pkg-config
    pkgs.python3
    xctoolchainLipo
  ];

  pname = import ../../utils/name/package.nix name;
  src = callPackage ../../utils/fetch-tarball/default.nix {
    name = "${pname}-source-${version}";
    inherit (packageLock) url sha256;
  };
  patchedSource = pkgs.runCommand "${pname}-patched-source-${variant}-${version}" { } ''
    cp -r ${src} src
    export src=$PWD/src
    chmod -R 777 $src

    cd $src
    patch -p1 <${../../../patches/mpv-fix-missing-objc.patch}
    patch -p1 <${../../../patches/mpv-mix-with-others.patch}
    if [ "${variant}" == "${variants.audio}" ]; then
      patch -p1 <${../../../patches/mpv-remove-libass.patch}
    fi
    cd -

    cp -r $src $out
  '';
  fixedSource = callPackage ../../utils/patch-shebangs/default.nix {
    name = "${pname}-fixed-source-${variant}-${version}";
    src = patchedSource;
    inherit nativeBuildInputs;
  };
in

pkgs.stdenvNoCC.mkDerivation {
  name = "${pname}-${os}-${arch}-${variant}-${version}";
  pname = pname;
  inherit version;
  src = fixedSource;
  dontUnpack = true;
  enableParallelBuilding = true;
  inherit nativeBuildInputs;
  buildInputs =
    [ ffmpeg ]
    ++ pkgs.lib.optionals (variant == "video") [
      uchardet
      libass
    ];
  configurePhase = ''
    DISABLE_ALL_OPTIONS=(
      `# booleans`
      -Dgpl=false `# GPL (version 2 or later) build`
      -Dcplayer=false `# mpv CLI player`
      -Dlibmpv=false `# libmpv library`
      -Dbuild-date=false `# whether to include binary compile time`
      -Dtests=false `# unit tests (development only)`
      -Dta-leak-report=false `# enable ta leak report by default (development only)`

      `# misc features`
      -Dcdda=disabled `# cdda support (libcdio)`
      -Dcplugins=disabled `# C plugins`
      -Ddvbin=disabled `# DVB input module`
      -Ddvdnav=disabled `# dvdnav support`
      -Diconv=disabled `# iconv`
      -Djavascript=disabled `# Javascript (MuJS backend)`
      -Dlcms2=disabled `# LCMS2 support`
      -Dlibarchive=disabled `# libarchive wrapper for reading zip files and more`
      -Dlibavdevice=disabled `# libavdevice`
      -Dlibbluray=disabled `# Bluray support`
      -Dlua=disabled `# Lua`
      -Dpthread-debug=disabled `# pthread runtime debugging wrappers`
      -Drubberband=disabled `# librubberband support`
      -Dsdl2=disabled `# SDL2`
      -Dsdl2-gamepad=disabled `# SDL2 gamepad input`
      -Dstdatomic=disabled `# C11 stdatomic.h`
      -Duchardet=disabled `# uchardet support`
      -Duwp=disabled `# Universal Windows Platform`
      -Dvapoursynth=disabled `# VapourSynth filter bridge`
      -Dvector=disabled `# GCC vector instructions`
      -Dwin32-internal-pthreads=disabled `#internal pthread wrapper for win32 (Vista+)`
      -Dzimg=disabled `# libzimg support (high quality software scaler)`
      -Dzlib=disabled `# zlib`

      `# audio output features`
      -Dalsa=disabled `# ALSA audio output`
      -Daudiounit=disabled `# AudioUnit output for iOS`
      -Dcoreaudio=disabled `# CoreAudio audio output`
      -Djack=disabled `# JACK audio output`
      -Dopenal=disabled `# OpenAL audio output`
      -Dopensles=disabled `# OpenSL ES audio output`
      -Doss-audio=disabled `# OSSv4 audio output`
      -Dpipewire=disabled `# PipeWire audio output`
      -Dpulse=disabled `# PulseAudio audio output`
      -Dsdl2-audio=disabled `# SDL2 audio output`
      -Dsndio=disabled `# sndio audio output`
      -Dwasapi=disabled `# WASAPI audio output`

      `# video output features`
      -Dcaca=disabled `# CACA`
      -Dcocoa=disabled `# Cocoa`
      -Dd3d11=disabled `# Direct3D 11 video output`
      -Ddirect3d=disabled `# Direct3D support`
      -Ddrm=disabled `# DRM`
      -Degl=disabled `# EGL 1.4`
      -Degl-android=disabled `# Android EGL support`
      -Degl-angle=disabled `# OpenGL ANGLE headers`
      -Degl-angle-lib=disabled `# OpenGL Win32 ANGLE library`
      -Degl-angle-win32=disabled `# OpenGL Win32 ANGLE Backend`
      -Degl-drm=disabled `# OpenGL DRM EGL Backend`
      -Degl-wayland=disabled `# OpenGL Wayland Backend`
      -Degl-x11=disabled `# OpenGL X11 EGL Backend`
      -Dgbm=disabled `# GBM`
      -Dgl=disabled `# OpenGL context support`
      -Dgl-cocoa=disabled `# gl-cocoa`
      -Dgl-dxinterop=disabled `# OpenGL/DirectX Interop Backend`
      -Dgl-win32=disabled `# OpenGL Win32 Backend`
      -Dgl-x11=disabled `# OpenGL X11/GLX (deprecated/legacy)`
      -Djpeg=disabled `# JPEG support`
      -Dlibplacebo=disabled `# libplacebo support`
      -Drpi=disabled `# Raspberry Pi support`
      -Dsdl2-video=disabled `# SDL2 video output`
      -Dshaderc=disabled `# libshaderc SPIR-V compiler`
      -Dsixel=disabled `# Sixel`
      -Dspirv-cross=disabled `# SPIRV-Cross SPIR-V shader converter`
      -Dplain-gl=disabled `# OpenGL without platform-specific code (e.g. for libmpv)`
      -Dvdpau=disabled `# VDPAU acceleration`
      -Dvdpau-gl-x11=disabled `# VDPAU with OpenGl/X11`
      -Dvaapi=disabled `# VAAPI acceleration`
      -Dvaapi-drm=disabled `# VAAPI (DRM/EGL support)`
      -Dvaapi-wayland=disabled `# VAAPI (Wayland support)`
      -Dvaapi-x11=disabled `# VAAPI (X11 support)`
      -Dvaapi-x-egl=disabled `# VAAPI EGL on X11`
      -Dvulkan=disabled `# Vulkan context support`
      -Dwayland=disabled `# Wayland`
      -Dx11=disabled `# X11`
      -Dxv=disabled `# Xv video output`

      `# hwaccel features`
      -Dandroid-media-ndk=disabled `# Android Media APIs`
      -Dcuda-hwaccel=disabled `# CUDA acceleration`
      -Dcuda-interop=disabled `# CUDA with graphics interop`
      -Dd3d-hwaccel=disabled `# D3D11VA hwaccel`
      -Dd3d9-hwaccel=disabled `# DXVA2 hwaccel`
      -Dgl-dxinterop-d3d9=disabled `# OpenGL/DirectX Interop Backend DXVA2 interop`
      -Dios-gl=disabled `# iOS OpenGL ES hardware decoding interop support`
      -Drpi-mmal=disabled `# Raspberry Pi MMAL hwaccel`
      -Dvideotoolbox-gl=disabled `# Videotoolbox with OpenGL`

      `# macOS features`
      -Dmacos-10-11-features=disabled `# macOS 10.11 SDK Features`
      -Dmacos-10-12-2-features=disabled `# macOS 10.12.2 SDK Features`
      -Dmacos-10-14-features=disabled `# macOS 10.14 SDK Features`
      -Dmacos-cocoa-cb=disabled `# macOS libmpv backend`
      -Dmacos-media-player=disabled `# macOS Media Player support`
      -Dmacos-touchbar=disabled `# macOS Touch Bar support`
      -Dswift-build=disabled `# macOS Swift build tools`
      -Dswift-flags= `# Optional Swift compiler flags`

      `# manpages`
      -Dhtml-build=disabled `# html manual generation`
      -Dmanpage-build=disabled `# manpage generation`
      -Dpdf-build=disabled `# pdf manual generation`
    )

    COMMON_OPTIONS=(
      `# booleans`
      -Dlibmpv=true `# libmpv library`
      -Dbuild-date=true `# whether to include binary compile time`

      `# misc features`
      -Diconv=enabled `# iconv`
    )

    COMMON_VIDEO_OPTIONS=(
      `# misc features`
      -Duchardet=enabled `# uchardet support`
      -Dzlib=enabled `# zlib`

      `# video output features`
      -Dgl=enabled `# OpenGL context support`
      -Dplain-gl=enabled `# OpenGL without platform-specific code (e.g. for libmpv)`
    )

    MACOS_OPTIONS=(
      `# audio output features`
      -Dcoreaudio=enabled `# CoreAudio audio output`

      `# video output features`
      -Dcocoa=enabled `# Cocoa` `# BUG: required in audio mode since v0.36.0`
    )

    MACOS_VIDEO_OPTIONS=(
      `# video output features`
      -Dgl-cocoa=enabled `# gl-cocoa`

      `# hwaccel features`
      -Dvideotoolbox-gl=enabled `# Videotoolbox with OpenGL`
    )

    IOS_OPTIONS=(
      `# audio output features`
      -Daudiounit=enabled `# AudioUnit output for iOS`
    )

    IOS_VIDEO_OPTIONS=(
      `# hwaccel features`
      -Dios-gl=enabled `# iOS OpenGL ES hardware decoding interop support`
    )

    OPTIONS=("''${DISABLE_ALL_OPTIONS[@]}")

    OPTIONS+=("''${COMMON_OPTIONS[@]}")
    if [ "${variant}" == "${variants.video}" ]; then
      OPTIONS+=("''${COMMON_VIDEO_OPTIONS[@]}")
    fi

    if [ "${os}" == "${oses.macos}" ]; then
      OPTIONS+=("''${MACOS_OPTIONS[@]}")
      if [ "${variant}" == "${variants.video}" ]; then
        OPTIONS+=("''${MACOS_VIDEO_OPTIONS[@]}")
      fi
    elif [ "${os}" == "${oses.ios}" ]; then
      OPTIONS+=("''${IOS_OPTIONS[@]}")
      if [ "${variant}" == "${variants.video}" ]; then
        OPTIONS+=("''${IOS_VIDEO_OPTIONS[@]}")
      fi
    fi

    meson setup build $src \
      --native-file ${nativeFile} \
      --cross-file ${crossFile} \
      --prefix=$out \
      "''${OPTIONS[@]}" |
      tee configure.log
  '';
  buildPhase = ''
    meson compile -vC build
  '';
  installPhase = ''
    meson install -C build

    # copy configure.log
    mkdir -p $out/share/mpv
    cp configure.log $out/share/mpv/
  '';
}
