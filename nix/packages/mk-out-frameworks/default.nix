{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix { },
  variant ? import ../../utils/default/variant.nix,
  flavor ? import ../../utils/default/flavor.nix,
}:

let
  name = "frameworks";
  version = import ../../utils/default/version.nix;
  callPackage = pkgs.lib.callPackageWith {
    inherit
      pkgs
      os
      arch
      variant
      flavor
      ;
  };
  pname = import ../../utils/name/output.nix name;
  oses = import ../../utils/constants/oses.nix;
  xctoolchainInstallNameTool = callPackage ../../utils/xctoolchain/install-name-tool.nix { };
  xctoolchainLipo = callPackage ../../utils/xctoolchain/lipo.nix { };
  xctoolchainOtool = callPackage ../../utils/xctoolchain/otool.nix { };
  xctoolchainPlutil = callPackage ../../utils/xctoolchain/plutil.nix { };
  xctoolchainVtool = callPackage ../../utils/xctoolchain/vtool.nix { };
  buildIOSScript = callPackage ../../utils/patch-shebangs/default.nix {
    name = "${pname}-build-ios.sh";
    src = ./ios/build-ios.sh;
  };
  buildMacOSScript = callPackage ../../utils/patch-shebangs/default.nix {
    name = "${pname}-build-macos.sh";
    src = ./macos/build-macos.sh;
  };

  libs = callPackage ../mk-out-libs/default.nix { };
in

pkgs.stdenvNoCC.mkDerivation {
  name = "${pname}-${os}-${arch}-${variant}-${flavor}-${version}";
  pname = pname;
  inherit version;
  enableParallelBuilding = true;
  nativeBuildInputs = [
    xctoolchainInstallNameTool
    xctoolchainLipo
    xctoolchainOtool
    xctoolchainPlutil
    xctoolchainVtool
  ];
  dontUnpack = true;
  buildPhase = ''
    mkdir build

    export DEPS=${libs}
    export OUTPUT_DIR=$PWD/build

    if [ ${os} == ${oses.macos} ]; then
      export INFO_PLIST_PATH=${./macos/Info.plist}
      ${buildMacOSScript}
    elif [ ${os} == ${oses.ios} ] || [ ${os} == ${oses.iossimulator} ]; then
      export INFO_PLIST_PATH=${./ios/Info.plist}
      ${buildIOSScript}
    else
      echo "Error: Unsupported os ${os}"
      exit 1
    fi
  '';
  installPhase = ''
    cp -r ./build $out
  '';
}
