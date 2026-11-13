#!/bin/bash
set -euo pipefail
repo_root=$(cd "$(dirname "$0")/.." && pwd)
test_root=$(mktemp -d "${TMPDIR:-/tmp}/mpv-apple-tls.XXXXXX")
trap 'rm -rf "$test_root"' EXIT

read -r source_url source_hash < <(python3 - "$repo_root/packages.lock.nix" <<'PY'
import pathlib, re, sys
text = pathlib.Path(sys.argv[1]).read_text()
block = re.search(r'  ffmpeg = \{(.*?)\n  \};', text, re.S)[1]
print(re.search(r'url = "([^"]+)"', block)[1], re.search(r'sha256 = "([^"]+)"', block)[1])
PY
)
curl --fail --location --retry 3 "$source_url" --output "$test_root/ffmpeg.tar.xz"
echo "$source_hash  $test_root/ffmpeg.tar.xz" | shasum -a 256 -c -
mkdir "$test_root/source"
tar -xf "$test_root/ffmpeg.tar.xz" --strip-components 1 -C "$test_root/source"
cd "$test_root/source"
./configure --disable-everything --disable-autodetect --disable-programs \
  --disable-doc --disable-x86asm --enable-network --enable-securetransport \
  --enable-protocol=tls,tcp --enable-small > "$test_root/configure.log" 2>&1 || {
    cat "$test_root/configure.log"
    exit 1
  }
make -j "$(sysctl -n hw.logicalcpu)" libavformat/libavformat.a \
  libavcodec/libavcodec.a libavutil/libavutil.a > "$test_root/build.log" 2>&1 || {
    tail -80 "$test_root/build.log"
    exit 1
  }
cc "$repo_root/tests/apple_tls.c" -I . -L libavformat -L libavcodec -L libavutil \
  -lavformat -lavcodec -lavutil -framework Security -framework CoreFoundation \
  -lm -lpthread -o "$test_root/apple_tls"
"$test_root/apple_tls" tls://www.bilibili.com:443 1
"$test_root/apple_tls" tls://badssl.com:443 1
"$test_root/apple_tls" tls://expired.badssl.com:443 0
"$test_root/apple_tls" tls://wrong.host.badssl.com:443 0
"$test_root/apple_tls" tls://self-signed.badssl.com:443 0
