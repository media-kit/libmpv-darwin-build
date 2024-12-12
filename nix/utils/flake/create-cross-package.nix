{
  pkgs ? import ../default/pkgs.nix,
  packageFn,
  packageName,
  format ? null,
  os,
  arch,
  variant ? null,
  flavor ? null,
}:

{
  name =
    packageName
    + (if format != null then "-${format}" else "")
    + "-${os}-${arch}"
    + (if variant != null then "-${variant}" else "")
    + (if flavor != null then "-${flavor}" else "");
  value = pkgs.callPackage packageFn (
    (if format != null then { inherit format; } else { })
    // {
      inherit os arch;
    }
    // (if variant != null then { inherit variant; } else { })
    // (if flavor != null then { inherit flavor; } else { })
  );
}
