The slug `mk-` is added in front of each package name to avoid conflicts with
the packages from `pkgs`. This prevents a package from being overridden by
nix/flake, as is the case with `libxml2`.
