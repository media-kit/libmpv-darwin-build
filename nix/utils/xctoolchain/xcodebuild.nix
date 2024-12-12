{
  pkgs ? import ../default/pkgs.nix,
}:

let
  xctoolchainSwiftc = pkgs.callPackage ./swiftc.nix { };
  xctoolchainVtool = pkgs.callPackage ../../utils/xctoolchain/vtool.nix { };
  xcodebuild = pkgs.stdenvNoCC.mkDerivation {
    name = "mk-xctoolchain-xcodebuild-bin";
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
        ${./xcodebuild.swift} -o ./build/bin/xcodebuild
    '';
    installPhase = ''
      cp -r ./build $out
    '';
  };
in

pkgs.runCommand "mk-xctoolchain-xcodebuild" { } ''
  mkdir -p build/bin

  cat > build/bin/xcodebuild <<EOF
  #!/usr/bin/env sh

  export PATH=${xctoolchainVtool}/bin:$PATH
  ${xcodebuild}/bin/xcodebuild "\$@"
  EOF

  chmod +x build/bin/xcodebuild
  patchShebangs build/bin/xcodebuild

  cp -r build $out
''
