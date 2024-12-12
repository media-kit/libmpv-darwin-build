{
  pkgs ? import ../../utils/default/pkgs.nix,
}:

let
  name = "all";
  version = import ../../utils/default/version.nix;

  pname = import ../../utils/name/output.nix name;
  flavors = import ../../utils/default/flavors.nix;
  variants = import ../../utils/default/variants.nix;
  targets = import ../mk-out-archive/targets.nix;
  archives = builtins.concatMap (
    target:
    builtins.concatMap (
      variant:
      builtins.map (
        flavor:
        let
          format = target.format;
          os = target.os;
          arch = target.arch;
        in
        import ../mk-out-archive/default.nix {
          inherit
            pkgs
            format
            os
            arch
            variant
            flavor
            ;
        }
      ) flavors
    ) variants
  ) targets;
in

pkgs.stdenvNoCC.mkDerivation {
  name = "${pname}";
  pname = pname;
  inherit version;
  dontUnpack = true;
  enableParallelBuilding = true;
  buildPhase = ''
    mkdir build

    ARCHIVES="${pkgs.lib.concatStringsSep " " archives}"
    for ARCHIVE in $ARCHIVES; do
      echo $ARCHIVE
      cp --no-preserve=mode $ARCHIVE/*.tar.gz build/
    done
  '';
  installPhase = ''
    cp -r build $out
  '';
}
