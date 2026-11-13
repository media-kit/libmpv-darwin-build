import pathlib
import plistlib
import sys

frameworks = list(pathlib.Path(sys.argv[1]).glob("*/*.xcframework"))
assert frameworks, "No XCFrameworks found"
for framework in frameworks:
    info = plistlib.loads((framework / "Info.plist").read_bytes())
    libraries = info["AvailableLibraries"]
    assert len(libraries) == 2, framework
    variants = set()
    for library in libraries:
        assert library["SupportedPlatform"] == "ios", (framework, library)
        variant = library.get("SupportedPlatformVariant", "device")
        variants.add(variant)
        expected = {"arm64"} if variant == "device" else {"arm64", "x86_64"}
        assert set(library["SupportedArchitectures"]) == expected, (framework, library)
        binary = framework / library["LibraryIdentifier"] / library["BinaryPath"]
        assert binary.is_file(), binary
    assert variants == {"device", "simulator"}, framework
    print(f"{framework.name}: iOS device and simulator metadata verified")
