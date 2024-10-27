{
  pkgs ? import ../../utils/default/pkgs.nix,
  format ? import ../../utils/default/format.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix { },
  variant ? import ../../utils/default/variant.nix,
  flavor ? import ../../utils/default/flavor.nix,
}:

let
  name = "archive";
  version = import ../../utils/default/version.nix;

  callPackage = pkgs.lib.callPackageWith {
    inherit
      pkgs
      os
      arch
      variant
      flavor
      ;
  };

  pname = import ../../utils/name/output.nix name;
  formats = import ../../utils/constants/formats.nix;
  archiveName = "libmpv-${format}_${version}_${os}-${arch}-${variant}-${flavor}.tar.gz";
  src =
    if format == formats.libs then
      callPackage ../mk-out-libs/default.nix { }
    else if format == formats.xcframeworks then
      callPackage ../mk-out-xcframeworks/default.nix { }
    else
      abort "Format ${format} is not supported";
in

pkgs.stdenvNoCC.mkDerivation {
  name = "${pname}-${format}-${os}-${arch}-${variant}-${flavor}-${version}";
  pname = pname;
  inherit version;
  dontUnpack = true;
  enableParallelBuilding = true;
  inherit src;
  buildPhase = ''
    mkdir build

    DIRNAME=$(basename ${archiveName} .tar.gz)

    cp --no-preserve=mode -r $src $DIRNAME
    tar -czvf build/${archiveName} $DIRNAME
  '';
  installPhase = ''
    cp -r build $out
  '';
}
