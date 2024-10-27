{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix { },
}:

let
  name = "harfbuzz";
  version = "8.1.1";
  url = "https://github.com/harfbuzz/harfbuzz/archive/8.1.1.tar.gz";
  # archiveSha256 = "b16e6bc0fc7e6a218583f40c7d201771f2e3072f85ef6e9217b36c1dc6b2aa25";
  sha256 = "1ghhzqs8kfmjaijvb64zryh2h9bzz6n2ryyq7s9jy0cy173s5sim";

  callPackage = pkgs.lib.callPackageWith { inherit pkgs os arch; };
  nativeFile = callPackage ../../utils/native-file/default.nix { };
  crossFile = callPackage ../../utils/cross-file/default.nix { };

  nativeBuildInputs = [
    pkgs.meson
    pkgs.ninja
    pkgs.pkg-config
    pkgs.python3
  ];

  pname = import ../../utils/name/package.nix name;
  src = builtins.fetchTarball {
    name = "${pname}-source-${version}";
    inherit url;
    inherit sha256;
  };
  patchedSource = callPackage ../../utils/patch-shebangs/default.nix {
    name = "${pname}-patched-source-${version}";
    inherit src;
    inherit nativeBuildInputs;
  };
in

pkgs.stdenvNoCC.mkDerivation {
  name = "${pname}-${os}-${arch}-${version}";
  pname = pname;
  inherit version;
  src = patchedSource;
  dontUnpack = true;
  enableParallelBuilding = true;
  inherit nativeBuildInputs;
  configurePhase = ''
    meson setup build $src \
      --native-file ${nativeFile} \
      --cross-file ${crossFile} \
      --prefix=$out \
      -Dglib=disabled \
      -Dgobject=disabled \
      -Dcairo=disabled \
      -Dchafa=disabled \
      -Dicu=disabled \
      -Dgraphite=disabled \
      -Dgraphite2=disabled \
      -Dfreetype=disabled \
      -Dgdi=disabled \
      -Ddirectwrite=disabled \
      -Dcoretext=enabled \
      -Dtests=disabled \
      -Dintrospection=disabled \
      -Ddocs=disabled \
      -Dbenchmark=disabled \
      -Dicu_builtin=false \
      -Dexperimental_api=false \
      -Dragel_subproject=false \
      -Dfuzzer_ldflags=
  '';
  buildPhase = ''
    meson compile -vC build
  '';
  installPhase = ''
    meson install -C build
  '';
}
