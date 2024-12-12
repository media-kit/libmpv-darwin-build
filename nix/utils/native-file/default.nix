{
  pkgs ? import ../default/pkgs.nix,
}:

let
  os = import ../default/os.nix;
  arch = pkgs.callPackage ../default/arch.nix { };
in

pkgs.callPackage ../cross-file/default.nix {
  inherit os arch;
}
