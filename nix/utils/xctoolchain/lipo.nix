{
  pkgs ? import ../default/pkgs.nix,
}:

# meson uses `lipo` directly from the $PATH instead of using `find_program`
# See https://github.com/mesonbuild/meson/blob/1.5.2/mesonbuild/utils/universal.py#L702
# TODO: Submit an upstream pull request to use `find_program('lipo')`
pkgs.runCommand "mk-xctoolchain-lipo" { } ''
  mkdir -p $out/bin
  ln -s ${pkgs.darwin.xcode}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/lipo $out/bin/lipo
''
