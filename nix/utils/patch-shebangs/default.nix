{
  pkgs ? import ../default/pkgs.nix,
  name,
  src,
  nativeBuildInputs ? [ ],
}:

pkgs.stdenvNoCC.mkDerivation {
  inherit name;
  inherit src;
  enableParallelBuilding = true;
  inherit nativeBuildInputs;
  unpackPhase = ''
    cp -r $src src
    export src=$PWD/src
    chmod -R 777 $src
  '';
  patchPhase = "true";
  configurePhase = "true";
  buildPhase = ''
    patchShebangs $src
  '';
  installPhase = ''
    cp -r $src $out
  '';
  fixupPhase = "true";
}
