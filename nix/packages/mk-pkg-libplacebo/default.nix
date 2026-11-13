{
  pkgs ? import ../../utils/default/pkgs.nix,
  os ? import ../../utils/default/os.nix,
  arch ? pkgs.callPackage ../../utils/default/arch.nix { },
}:

let
  locks = import ../../../packages.lock.nix;
  packageLock = locks.libplacebo;
  inherit (packageLock) version;

  callPackage = pkgs.lib.callPackageWith { inherit pkgs os arch; };
  nativeFile = callPackage ../../utils/native-file/default.nix { };
  crossFile = callPackage ../../utils/cross-file/default.nix { };
  fetch = name: lock: callPackage ../../utils/fetch-tarball/default.nix {
    name = "${name}-source-${lock.version}";
    inherit (lock) url sha256;
  };

  pname = import ../../utils/name/package.nix "libplacebo";
  src = fetch pname packageLock;
  fastFloat = fetch "fast-float" locks.fast_float;
  glad = fetch "glad" locks.glad;
  jinja = fetch "jinja" locks.jinja;
  markupsafe = fetch "markupsafe" locks.markupsafe;
  vulkanHeaders = fetch "vulkan-headers" locks.vulkan_headers;
  source = pkgs.runCommand "${pname}-source-with-submodules-${version}" { } ''
    cp -r ${src} src
    chmod -R 777 src
    rm -rf src/3rdparty/{fast_float,glad,jinja,markupsafe,Vulkan-Headers}
    mkdir -p src/3rdparty
    cp -r ${fastFloat} src/3rdparty/fast_float
    cp -r ${glad} src/3rdparty/glad
    cp -r ${jinja} src/3rdparty/jinja
    cp -r ${markupsafe} src/3rdparty/markupsafe
    cp -r ${vulkanHeaders} src/3rdparty/Vulkan-Headers
    cp -r src $out
  '';
in

pkgs.stdenvNoCC.mkDerivation {
  name = "${pname}-${os}-${arch}-${version}";
  inherit pname version;
  src = source;
  dontUnpack = true;
  enableParallelBuilding = true;
  nativeBuildInputs = [
    pkgs.meson
    pkgs.ninja
    pkgs.pkg-config
    pkgs.python3
  ];
  configurePhase = ''
    meson setup build $src \
      --native-file ${nativeFile} \
      --cross-file ${crossFile} \
      --prefix=$out \
      -Ddefault_library=shared \
      -Ddemos=false \
      -Dtests=false \
      -Dbench=false \
      -Dfuzz=false \
      -Dvulkan=disabled \
      -Dopengl=enabled \
      -Dgl-proc-addr=disabled \
      -Dd3d11=disabled \
      -Dglslang=disabled \
      -Dshaderc=disabled \
      -Dlcms=disabled \
      -Ddovi=disabled \
      -Dlibdovi=disabled \
      -Dunwind=disabled \
      -Dxxhash=disabled
  '';
  buildPhase = ''
    meson compile -vC build
  '';
  installPhase = ''
    meson install -C build
  '';
}
