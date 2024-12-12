{
  pkgs ? import ../../utils/default/pkgs.nix,
}:

if pkgs.system == "aarch64-darwin" then
  "arm64"
else if pkgs.system == "x86_64-darwin" then
  "amd64"
else
  abort "System ${pkgs.system} is not supported"
