{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix { },
}:

let
  name = "dav1d";
  version = "1.2.1";
  url = "https://code.videolan.org/videolan/dav1d/-/archive/1.2.1/dav1d-1.2.1.tar.bz2";
  # archiveSha256 ="a4003623cdc0109dec3aac8435520aa3fb12c4d69454fa227f2658cdb6dab5fa";
  sha256 = "1hjpb97wh740zrbxcdyisj21nx0z1xy2nfs58mv3qpnpf6dj5ca6";

  callPackage = pkgs.lib.callPackageWith { inherit pkgs os arch; };
  nativeFile = callPackage ../../utils/native-file/default.nix { };
  crossFile = callPackage ../../utils/cross-file/default.nix { };

  pname = import ../../utils/name/package.nix name;
  src = builtins.fetchTarball {
    name = "${pname}-source-${version}";
    inherit url;
    inherit sha256;
  };
in

pkgs.stdenvNoCC.mkDerivation {
  name = "${pname}-${os}-${arch}-${version}";
  pname = pname;
  inherit version;
  inherit src;
  dontUnpack = true;
  enableParallelBuilding = true;
  nativeBuildInputs = [
    pkgs.meson
    pkgs.ninja
    pkgs.pkg-config
  ];
  configurePhase = ''
    meson setup build $src \
      --native-file ${nativeFile} \
      --cross-file ${crossFile} \
      --prefix=$out \
      -Dbitdepths="['8', '16']" \
      -Denable_asm=false \
      -Denable_tools=false \
      -Denable_examples=false \
      -Denable_tests=false \
      -Denable_docs=false \
      -Dlogging=true \
      -Dtestdata_tests=false \
      -Dfuzzing_engine=none \
      -Dfuzzer_ldflags= \
      -Dstack_alignment=0 \
      -Dxxhash_muxer=auto \
      -Dtrim_dsp=if-release
  '';
  buildPhase = ''
    meson compile -vC build
  '';
  installPhase = ''
    meson install -C build
  '';
}
