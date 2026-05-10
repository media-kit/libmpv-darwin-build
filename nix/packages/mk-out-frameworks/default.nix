{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix { },
  variant ? import ../../utils/default/variant.nix,
  flavor ? import ../../utils/default/flavor.nix,
}:

let
  name = "frameworks";
  version = import ../../utils/version/default.nix { inherit pkgs; };
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
  archs = import ../../utils/constants/archs.nix;
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

  # TODO: ideally headers (and the module map) should be bundled per-framework
  # derivation rather than injected globally from the dylib-based build loop.
  # For now, mpv headers are extracted separately and passed via env variables.
  #
  # For universal builds, arm64 headers are used as they are very likely
  # identical to their amd64 counterparts.
  mpvHeaders =
    let
      mpv = callPackage ../mk-pkg-mpv/default.nix {
        arch = if arch == archs.universal then archs.arm64 else arch;
      };
    in
    pkgs.runCommand "mpv-headers" { } ''
      mkdir -p $out
      cp -r ${mpv}/include/mpv/*.h $out/
    '';
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

    export MPV_HEADERS_PATH=${mpvHeaders}
    export MPV_MODULE_MAP_PATH=${./common/mpv/module.modulemap}

    if [ ${os} == ${oses.macos} ]; then
      export INFO_PLIST_PATH=${./macos/Info.plist}
      ${buildMacOSScript}
    elif [ ${os} == ${oses.ios} ] || [ ${os} == ${oses.iossimulator} ] || [ ${os} == ${oses.tvos} ] || [ ${os} == ${oses.tvossimulator} ]; then
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
