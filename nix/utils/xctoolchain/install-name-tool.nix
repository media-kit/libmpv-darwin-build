{
  pkgs ? import ../default/pkgs.nix,
}:

pkgs.runCommand "mk-xctoolchain-install-name-tool" { } ''
  mkdir -p $out/bin
  ln -s ${pkgs.darwin.xcode}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/install_name_tool $out/bin/install_name_tool
''
