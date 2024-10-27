{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix { },
}:

let
  name = "mbedtls";
  version = "3.4.1";
  url = "https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/v3.4.1.tar.gz";
  # archiveSha256 = "a420fcf7103e54e775c383e3751729b8fb2dcd087f6165befd13f28315f754f5";
  sha256 = "0fzm1a02r4mkhawxdgk6rr7pv9dp94z4yrg4xd9sk0svqm2z521l";

  callPackage = pkgs.lib.callPackageWith { inherit pkgs os arch; };
  nativeFile = callPackage ../../utils/native-file/default.nix { };
  crossFile = callPackage ../../utils/cross-file/default.nix { };

  pname = import ../../utils/name/package.nix name;
  src = builtins.fetchTarball {
    name = "${pname}-source-${version}";
    inherit url;
    inherit sha256;
  };
  patchedSource = pkgs.runCommand "${pname}-patched-source-${version}" { } ''
    mkdir -p $out/subprojects/mbedtls
    cp -r ${src}/* $out/subprojects/mbedtls/
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
    pkgs.python3
  ];
  configurePhase = ''
    meson setup build $src \
      --native-file ${nativeFile} \
      --cross-file ${crossFile} \
      --prefix=$out
  '';
  buildPhase = ''
    meson compile -vC build
  '';
  installPhase = ''
    # create output layout
    mkdir -p $out/{include,lib}
    mkdir -p $out/include/{mbedtls,psa}
    mkdir -p $out/lib/pkgconfig

    # install headers
    cp $src/subprojects/mbedtls/include/mbedtls/*.h $out/include/mbedtls/
    cp $src/subprojects/mbedtls/include/psa/*.h $out/include/psa/

    # install libs
    find build -type f -name '*.dylib' -exec sh -c 'cp {} $out/lib/' \;

    # install pkgconfig file
    cp ${./mbedtls.pc.in} $out/lib/pkgconfig/mbedtls.pc
    sed -i "s|\''${PREFIX}|$out|g" $out/lib/pkgconfig/mbedtls.pc
    sed -i "s|\''${VERSION}|${version}|g" $out/lib/pkgconfig/mbedtls.pc
  '';
}
