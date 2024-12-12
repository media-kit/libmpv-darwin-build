{
  pkgs ? import ../default/pkgs.nix,
  path ? ../../packages,
}:

let
  createCrossPackage = pkgs.callPackage ./create-cross-package.nix;
  packagesWithTargets = import ./packages-with-targets.nix {
    inherit pkgs;
    inherit path;
  };
  variants = import ../default/variants.nix;
  flavors = import ../default/flavors.nix;
  crossPackagesMap = builtins.concatMap (
    packageName:
    let
      targets = import (path + "/${packageName}/targets.nix");
    in
    builtins.concatMap (
      target:
      let
        format = if (builtins.elem "format" (builtins.attrNames target)) then target.format else null;
        os = target.os;
        arch = target.arch;
        packageFn = import (path + "/${packageName}/default.nix");
        args = builtins.attrNames (builtins.functionArgs packageFn);
        supportsFormat = format != null && builtins.elem "format" args;
        supportsVariant = builtins.elem "variant" args;
        supportsFlavor = builtins.elem "flavor" args;
      in
      if supportsVariant && supportsFlavor then
        builtins.concatMap (
          variant:
          builtins.map (
            flavor:
            (createCrossPackage (
              {
                inherit
                  packageFn
                  packageName
                  os
                  arch
                  variant
                  flavor
                  ;
              }
              // (if supportsFormat then { inherit format; } else { })
            ))
          ) flavors
        ) variants
      else if supportsVariant then
        builtins.map (
          variant:
          (createCrossPackage (
            {
              inherit
                packageFn
                packageName
                os
                arch
                variant
                ;
            }
            // (if supportsFormat then { inherit format; } else { })
          ))
        ) variants
      else
        [
          (createCrossPackage (
            {
              inherit
                packageFn
                packageName
                os
                arch
                ;
            }
            // (if supportsFormat then { inherit format; } else { })
          ))
        ]
    ) targets
  ) packagesWithTargets;
in

pkgs.lib.listToAttrs crossPackagesMap
