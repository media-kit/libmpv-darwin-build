let
  oses = import ../constants/oses.nix;
  archs = import ../constants/archs.nix;
in
[
  {
    os = oses.ios;
    arch = archs.universal;
  }
  {
    os = oses.macos;
    arch = archs.universal;
  }
]
