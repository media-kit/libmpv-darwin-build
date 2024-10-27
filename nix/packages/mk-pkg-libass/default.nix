{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix { },
}:

let
  name = "libass";
  version = "0.17.1";
  url = "https://github.com/libass/libass/releases/download/0.17.1/libass-0.17.1.tar.xz";
  # archiveSha256 = "f0da0bbfba476c16ae3e1cfd862256d30915911f7abaa1b16ce62ee653192784";
  sha256 = "19qwqss8m451zc7vhi7prcc44s0dxg8k0ys5q89iinkc2lpifj1d";

  callPackage = pkgs.lib.callPackageWith { inherit pkgs os arch; };
  nativeFile = callPackage ../../utils/native-file/default.nix { };
  crossFile = callPackage ../../utils/cross-file/default.nix { };
  fribidi = callPackage ../mk-pkg-fribidi/default.nix { };
  harfbuzz = callPackage ../mk-pkg-harfbuzz/default.nix { };
  freetype = callPackage ../mk-pkg-freetype/default.nix { };

  pname = import ../../utils/name/package.nix name;
  src = builtins.fetchTarball {
    name = "${pname}-source-${version}";
    inherit url;
    inherit sha256;
  };
  patchedSource = pkgs.runCommand "${pname}-patched-source-${version}" { } ''
    cp -r ${src} src
    export src=$PWD/src
    chmod -R 777 $src

    cd $src
    patch -p1 <${../../../patches/ltmain-target-passthrough.patch}
    cd -

    cp ${./meson.build} $src/meson.build

    cp -r $src $out
  '';
in

pkgs.stdenvNoCC.mkDerivation {
  name = "${pname}-${os}-${arch}-${version}";
  pname = pname;
  inherit version;
  src = patchedSource;
  dontUnpakck = true;
  enableParallelBuilding = true;
  nativeBuildInputs = [
    pkgs.meson
    pkgs.ninja
    pkgs.pkg-config
  ];
  buildInputs = [
    fribidi
    harfbuzz
    freetype
  ];
  configurePhase = ''
    meson setup build $src \
      --native-file ${nativeFile} \
      --cross-file ${crossFile} \
      --prefix=$out
  '';
  buildPhase = ''
    meson compile -vC build $(basename $src)
  '';
  installPhase = ''
    # manual install to preserve symlinks (meson install -C build)
    mkdir $out
    cp -R build/dist$out/* $out/
  '';
}
