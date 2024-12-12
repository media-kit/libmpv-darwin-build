{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix { },
  variant ? import ../../utils/default/variant.nix,
  flavor ? import ../../utils/default/flavor.nix,
}:

let
  name = "xcframeworks";
  version = import ../../utils/default/version.nix;
  pname = import ../../utils/name/output.nix name;
  oses = import ../../utils/constants/oses.nix;
  callPackage = pkgs.lib.callPackageWith {
    inherit
      pkgs
      arch
      variant
      flavor
      ;
  };
  xctoolchainXcodebuild = callPackage ../../utils/xctoolchain/xcodebuild.nix { };
  frameworks =
    if os == oses.ios then
      [
        (callPackage ../mk-out-frameworks/default.nix { os = oses.ios; })
        (callPackage ../mk-out-frameworks/default.nix { os = oses.iossimulator; })
      ]
    else if os == oses.macos then
      [
        (callPackage ../mk-out-frameworks/default.nix { os = oses.macos; })
      ]
    else
      abort "Os ${os} is not supported";
in

pkgs.stdenvNoCC.mkDerivation {
  name = "${pname}-${os}-${arch}-${variant}-${flavor}-${version}";
  pname = pname;
  inherit version;
  enableParallelBuilding = true;
  nativeBuildInputs = [
    xctoolchainXcodebuild
  ];
  dontUnpack = true;
  buildPhase = ''
    mkdir ./build

    FRAMEWORKS="${pkgs.lib.concatStringsSep " " frameworks}"
    echo $FRAMEWORKS
    read -a FRAMEWORKS <<< "$FRAMEWORKS"

    for FRAMEWORK in ''${FRAMEWORKS[0]}/*.framework; do
      FRAMEWORK_NAME=$(basename $FRAMEWORK)
      FRAMEWORK_BASENAME=$(basename $FRAMEWORK .framework)
      echo $FRAMEWORK_NAME

      XCODEBUILD_CMD="xcodebuild -verbose -create-xcframework"

      for FRAMEWORKS_DIR in ''${FRAMEWORKS[@]}; do
        if [ -d $FRAMEWORKS_DIR/$FRAMEWORK_NAME ]; then
          XCODEBUILD_CMD+=" -framework $FRAMEWORKS_DIR/$FRAMEWORK_NAME"
        else
          echo "Error: $FRAMEWORK_NAME not found in $FRAMEWORKS_DIR" 2> /dev/stderr
          exit 1
        fi
      done

      XCODEBUILD_CMD+=" -output ./build/$FRAMEWORK_BASENAME.xcframework"

      echo $XCODEBUILD_CMD
      eval "$XCODEBUILD_CMD"
    done
  '';
  installPhase = ''
    cp -r ./build $out
  '';
}
