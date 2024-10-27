{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix { },
}:

let
  name = "libvpx";
  version = "1.13.0+1";
  url = "https://gitlab.freedesktop.org/gstreamer/meson-ports/libvpx/-/archive/90d26fac0d895969a82cd873ad36e39737104c44/libvpx-v1.13.0.tar.gz";
  # archiveSha256= "4f872ad2709d17b848b3588231495e432c42b9263731b9121fa210a3c5a893ff";
  sha256 = "07g3gmbg24clqc414yb5mhss0q2lkav698lhfpgsb0cqm08lddi7";

  callPackage = pkgs.lib.callPackageWith { inherit pkgs os arch; };
  nativeFile = callPackage ../../utils/native-file/default.nix { };
  crossFile = callPackage ../../utils/cross-file/default.nix { };

  # Presence required during the configure phase and used only with
  # iossimulator to get sdk path, pkgs.xcbuild provides xcrun, but is not
  # maintained
  xcrun = pkgs.writeShellScriptBin "xcrun" ''
    # Variables
    sdk=""
    show_sdk_version=false

    # Parsing arguments
    while [[ "$#" -gt 0 ]]; do
      case $1 in
        --sdk) sdk="$2"; shift ;;
        --show-sdk-version) show_sdk_version=true ;;
        *) echo "Option inconnue: $1" >&2; exit 1 ;;
      esac
      shift
    done

    # Execute if --sdk iphonesimulator and --show-sdk-version are present
    if [[ "$sdk" == "iphonesimulator" && "$show_sdk_version" == true ]]; then
      echo ${pkgs.darwin.xcode}/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
      exit 0
    else
      echo UNIMPLEMETED
      exit 1
    fi
  '';

  nativeBuildInputs = [
    pkgs.meson
    pkgs.nasm
    pkgs.yasm
    pkgs.ninja
    pkgs.pkg-config
    pkgs.python3
    xcrun
  ];

  pname = import ../../utils/name/package.nix name;
  src = builtins.fetchTarball {
    name = "${pname}-source-${version}";
    inherit url;
    inherit sha256;
  };
  patchedSource = callPackage ../../utils/patch-shebangs/default.nix {
    name = "${pname}-patched-source-${version}";
    inherit src;
    inherit nativeBuildInputs;
  };
in

pkgs.stdenvNoCC.mkDerivation {
  name = "${pname}-${os}-${arch}-${version}";
  pname = pname;
  inherit version;
  src = patchedSource;
  dontUnpack = true;
  enableParallelBuilding = true;
  inherit nativeBuildInputs;
  configurePhase = ''
    meson setup build $src \
      --native-file ${nativeFile} \
      --cross-file ${crossFile} \
      --prefix=$out \
      -Ddefault_library=shared
  '';
  buildPhase = ''
    meson compile -vC build
  '';
  installPhase = ''
    meson install -C build
  '';
}
