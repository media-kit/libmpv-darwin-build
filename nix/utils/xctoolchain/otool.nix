{
  pkgs ? import ../default/pkgs.nix,
}:

pkgs.runCommand "mk-xctoolchain-otool" { } ''
  mkdir -p $out/bin
  ln -s ${pkgs.darwin.xcode}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/otool $out/bin/otool
''
