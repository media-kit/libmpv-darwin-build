## Minimal linux workflow to build minimal libmpv with opengl support

```shell
$ docker run --rm -v $(pwd):$(pwd) -w $(pwd) -ti debian:bookworm-slim bash

$ apt update && apt install -y --no-install-recommends \
    ca-certificates curl meson pkg-config clang \
    libavcodec-dev \
    libavfilter-dev \
    libass-dev

$ export MPV_VERSION=0.35.1
$ curl -L https://github.com/mpv-player/mpv/archive/refs/tags/v${MPV_VERSION}.tar.gz -o mpv-${MPV_VERSION}.tar.gz
$ mkdir mpv && tar -xvf mpv-${MPV_VERSION}.tar.gz --strip-components 1 -C mpv

$ cd mpv
# see meson_options.txt for options
$ meson setup build \
    -Dlibmpv=true \
    -Dgl=enabled \
    -Dcplayer=false
$ meson compile -C build mpv:shared_library

$ ldd build/libmpv.so
```

## Notes

```shell
$ meson setup build --cross-file ../darwin-arm64.ini
```

## Resources

- https://github.com/stps/mpv-ios-scripts
- https://github.com/iina/homebrew-mpv-iina
- https://github.com/mpv-android/mpv-android
- https://github.com/jnozsc/mpv-nightly-build
- https://github.com/smplayer-dev/mpv
- https://github.com/smplayer-dev/smplayer
- https://github.com/ldwardx/mpv-build-mac-iOS
