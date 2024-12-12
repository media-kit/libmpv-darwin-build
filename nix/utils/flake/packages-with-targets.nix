{
  pkgs ? import ../default/pkgs.nix,
  path ? ../../packages,
}:

let
  inherit (builtins) readDir;
  inherit (pkgs.lib)
    attrNames
    filter
    pathExists
    pipe
    ;
in

pipe (readDir path) [
  attrNames
  (filter (name: pathExists (path + "/${name}/default.nix")))
  (filter (name: pathExists (path + "/${name}/targets.nix")))
]
