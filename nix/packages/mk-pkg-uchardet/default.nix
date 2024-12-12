{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix { },
}:

let
  name = "uchardet";
  packageLock = (import ../../../packages.lock.nix).${name};
  inherit (packageLock) version;

  callPackage = pkgs.lib.callPackageWith { inherit pkgs os arch; };
  nativeFile = callPackage ../../utils/native-file/default.nix { };
  crossFile = callPackage ../../utils/cross-file/default.nix { };
  xctoolchainInstallNameTool = callPackage ../../utils/xctoolchain/install-name-tool.nix { };

  pname = import ../../utils/name/package.nix name;
  src = callPackage ../../utils/fetch-tarball/default.nix {
    name = "${pname}-source-${version}";
    inherit (packageLock) url sha256;
  };
  patchedSource = pkgs.runCommand "${pname}-patched-source-${version}" { } ''
    mkdir -p $out/subprojects/uchardet
    cp -r ${src}/* $out/subprojects/uchardet/
    cp ${./meson.build} $out/meson.build
  '';
in

pkgs.stdenvNoCC.mkDerivation {
  name = "${pname}-${os}-${arch}-${version}";
  pname = pname;
  inherit version;
  src = patchedSource;
  dontUnpack = true;
  enableParallelBuilding = true;
  nativeBuildInputs = [
    pkgs.cmake
    pkgs.meson
    pkgs.ninja
    pkgs.pkg-config
    xctoolchainInstallNameTool
  ];
  configurePhase = ''
    meson setup build $src \
      --native-file ${nativeFile} \
      --cross-file ${crossFile} \
      --prefix=$out
  '';
  buildPhase = ''
    meson compile -vC build libuchardet
  '';
  installPhase = ''
    # create output layout
    mkdir -p $out/{include,lib}
    mkdir -p $out/include/uchardet
    mkdir -p $out/lib/pkgconfig

    # install headers
    cp $src/subprojects/uchardet/src/uchardet.h $out/include/uchardet/

    # install libs
    cp build/subprojects/uchardet/liblibuchardet.dylib $out/lib/libuchardet.dylib
    install_name_tool -id @rpath/libuchardet.dylib $out/lib/libuchardet.dylib

    # install pkgconfig file
    cp ${./uchardet.pc.in} $out/lib/pkgconfig/uchardet.pc
    sed -i "s|\''${PREFIX}|$out|g" $out/lib/pkgconfig/uchardet.pc
    sed -i "s|\''${VERSION}|${version}|g" $out/lib/pkgconfig/uchardet.pc
  '';
}
