{
  pkgs ? import ../default/pkgs.nix,
}:

let
  xctoolchainSwiftc = pkgs.callPackage ./swiftc.nix { };
in

pkgs.stdenvNoCC.mkDerivation {
  name = "mk-xctoolchain-plutil";
  enableParallelBuilding = true;
  nativeBuildInputs = [
    xctoolchainSwiftc
  ];
  dontUnpack = true;
  buildPhase = ''
    mkdir -p ./build/bin

    swiftc \
      -sdk ${pkgs.darwin.xcode}/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
      -module-cache-path ./cache \
      ${./plutil.swift} -o ./build/bin/plutil
  '';
  installPhase = ''
    cp -r ./build $out
  '';
}
