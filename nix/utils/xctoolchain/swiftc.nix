{
  pkgs ? import ../default/pkgs.nix,
}:

pkgs.runCommand "mk-xctoolchain-swiftc" { } ''
  mkdir -p $out/{bin,nix-support}
  ln -s ${pkgs.darwin.xcode}/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc $out/bin/swiftc
  echo "export SDKROOT=${pkgs.darwin.xcode}/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk" > $out/nix-support/setup-hook
''
