let
  formats = import ../constants/formats.nix;
  libs = import ./libs-frameworks.nix;
  xcframeworks = import ./xcframeworks.nix;
in

(builtins.map (target: {
  format = formats.libs;
  inherit (target) os arch;
}) libs)
++ (builtins.map (target: {
  format = formats.xcframeworks;
  inherit (target) os arch;
}) xcframeworks)
