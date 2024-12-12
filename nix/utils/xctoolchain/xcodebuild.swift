// A lightweight clone of `xcodebuild` that creates an `.xcframework` from
// individual frameworks.
// This clone exists because the version of `xcodebuild` included in Xcode.app
// crashes when used with `nix.settings.sandbox = true`.

import Foundation

// Paths to the required executables
let fileCmdPath = try findExecutable("file")
let vtoolCmdPath = try findExecutable("vtool")

// Structure to store framework information
struct FrameworkInfo: Codable {
  let path: String
  let architectures: [String]
  let platform: String
  let variant: String?
}

// Parse command-line arguments to extract framework paths, output path, and verbosity flag
func parseArguments() -> (frameworkPaths: [String], outputPath: String, verbose: Bool) {
  var frameworkPaths: [String] = []
  var outputPath: String = ""
  var verbose: Bool = false

  var args = CommandLine.arguments
  args.removeFirst()  // Remove script path

  // Loop through arguments
  while let arg = args.first {
    switch arg {
    case "-framework":
      args.removeFirst()
      if let path = args.first {
        frameworkPaths.append(path)
        args.removeFirst()
      }
    case "-output":
      args.removeFirst()
      if let path = args.first {
        outputPath = path
        args.removeFirst()
      }
    case "-verbose":
      verbose = true
      args.removeFirst()
    default:
      args.removeFirst()
    }
  }
  return (frameworkPaths, outputPath, verbose)
}

// Determine architecture and platform information for a given framework path
func determineArchitectureAndPlatform(for frameworkPath: String) throws -> FrameworkInfo {
  let binaryPath = try findFrameworkBinaryPath(in: frameworkPath)
  let architectures = getArchitectures(usingFileCommandFor: binaryPath)
  let (platform, variant) = getPlatformAndVariant(
    usingVtoolFor: binaryPath, architectures: architectures)

  return FrameworkInfo(
    path: frameworkPath,
    architectures: architectures,
    platform: platform,
    variant: variant
  )
}

// Custom errors for framework processing
enum FrameworkError: Error {
  case pathNotFound(String)
  case unableToResolveLink(String)
}

// Locate the binary file within the framework path
func findFrameworkBinaryPath(in frameworkPath: String) throws -> String {
  let fileManager = FileManager.default
  let frameworkName = URL(fileURLWithPath: frameworkPath).lastPathComponent.replacingOccurrences(
    of: ".framework", with: "")
  var actualPath = "\(frameworkPath)/\(frameworkName)"

  // Resolve symbolic links to locate actual binary path
  while true {
    do {
      let attributes = try fileManager.attributesOfItem(atPath: actualPath)
      if let type = attributes[.type] as? FileAttributeType, type == .typeSymbolicLink {
        let destinationPath = try fileManager.destinationOfSymbolicLink(atPath: actualPath)
        let destinationURL = URL(fileURLWithPath: actualPath).deletingLastPathComponent()
          .appendingPathComponent(destinationPath)
        actualPath = destinationURL.path
      } else {
        break
      }
    } catch {
      throw FrameworkError.unableToResolveLink(
        "Error resolving path: \(error.localizedDescription)")
    }
  }

  guard fileManager.fileExists(atPath: actualPath) else {
    throw FrameworkError.pathNotFound("The binary path does not exist: \(actualPath)")
  }

  return actualPath
}

// Retrieve architecture information using the `file` command
func getArchitectures(usingFileCommandFor binaryPath: String) -> [String] {
  let process = Process()
  process.executableURL = URL(fileURLWithPath: fileCmdPath)
  process.arguments = [binaryPath]

  let pipe = Pipe()
  process.standardOutput = pipe
  try? process.run()

  let data = pipe.fileHandleForReading.readDataToEndOfFile()
  let output = String(data: data, encoding: .utf8) ?? ""

  var architectures: [String] = []
  if output.contains("arm64") { architectures.append("arm64") }
  if output.contains("x86_64") { architectures.append("x86_64") }
  return architectures
}

// Determine the platform and variant using `vtool` for each architecture
func getPlatformAndVariant(usingVtoolFor binaryPath: String, architectures: [String]) -> (
  platform: String, variant: String?
) {
  for architecture in architectures {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: vtoolCmdPath)
    process.arguments = ["-arch", architecture, "-show-build", binaryPath]

    let pipe = Pipe()
    process.standardOutput = pipe
    try? process.run()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""

    if output.contains("IOSSIMULATOR")
      || (output.contains("LC_VERSION_MIN_IPHONEOS") && architecture == "x86_64")
    {
      return ("ios", "simulator")
    } else if output.contains("LC_VERSION_MIN_IPHONEOS") && architecture == "arm64" {
      return ("ios", nil)
    } else if output.contains("LC_VERSION_MIN_MACOSX") || output.contains("MACOS") {
      return ("macos", nil)
    }
  }
  return ("unknown", nil)
}

// Generate a unique identifier for the framework based on platform, architectures, and variant
func frameworkIdentifier(for framework: FrameworkInfo) -> String {
  var identifier =
    "\(framework.platform)-\(framework.architectures.sorted().joined(separator: "_"))"
  if let variant = framework.variant {
    identifier.append("-\(variant)")
  }
  return identifier
}

// Create the XCFramework structure including the framework copies and the Info.plist file
func createXCFrameworkStructure(outputPath: String, frameworks: [FrameworkInfo], plistData: Data)
  throws
{
  let fileManager = FileManager.default
  try fileManager.createDirectory(
    atPath: outputPath, withIntermediateDirectories: true, attributes: nil)

  for framework in frameworks {
    let identifier = frameworkIdentifier(for: framework)
    let targetPath = "\(outputPath)/\(identifier)"
    try fileManager.createDirectory(
      atPath: targetPath, withIntermediateDirectories: true, attributes: nil)

    let frameworkName = framework.path.components(separatedBy: "/").last!
    let destinationPath = "\(targetPath)/\(frameworkName)"
    try fileManager.copyItem(atPath: framework.path, toPath: destinationPath)

    // Set permissions to rwxr-xr-x as xcodebuild does not handle permissions
    try setPermissions(for: destinationPath, to: 0o755)
  }

  let plistURL = URL(fileURLWithPath: "\(outputPath)/Info.plist")
  try plistData.write(to: plistURL)
}

// Set permissions for the given path and its contents
func setPermissions(for path: String, to mode: mode_t) throws {
  let fileManager = FileManager.default
  try fileManager.setAttributes([.posixPermissions: NSNumber(value: mode)], ofItemAtPath: path)

  if (try fileManager.attributesOfItem(atPath: path)[.type] as? FileAttributeType) == .typeDirectory
  {
    for item in try fileManager.contentsOfDirectory(atPath: path) {
      let itemPath = (path as NSString).appendingPathComponent(item)
      try setPermissions(for: itemPath, to: mode)
    }
  }
}

// Generate the Info.plist data required for XCFramework
func generateInfoPlistData(for frameworks: [FrameworkInfo]) throws -> Data {
  let plistDict: [String: Any] = [
    "CFBundlePackageType": "XFWK",
    "XCFrameworkFormatVersion": "1.0",
    "AvailableLibraries": frameworks.map { framework -> [String: Any] in
      var libraryDict: [String: Any] = [
        "LibraryIdentifier": frameworkIdentifier(for: framework),
        "LibraryPath": "\(framework.path.components(separatedBy: "/").last!)",
        "BinaryPath":
          "\(framework.path.components(separatedBy: "/").last!)/\(framework.path.components(separatedBy: "/").last!.replacingOccurrences(of: ".framework", with: ""))",
        "SupportedArchitectures": framework.architectures,
        "SupportedPlatform": framework.platform,
      ]
      if let variant = framework.variant {
        libraryDict["SupportedPlatformVariant"] = variant
      }
      return libraryDict
    },
  ]

  return try PropertyListSerialization.data(fromPropertyList: plistDict, format: .xml, options: 0)
}

// Format Info.plist data for display
func formatPlistData(_ plistData: Data) throws -> String {
  guard let plistString = String(data: plistData, encoding: .utf8) else {
    throw NSError(domain: "Invalid String Encoding", code: 1, userInfo: nil)
  }
  return plistString
}

// Utility to find an executable in the PATH
enum ExecutableError: Error {
  case notFound(String)
}

func findExecutable(_ name: String) throws -> String {
  guard let path = ProcessInfo.processInfo.environment["PATH"] else {
    throw ExecutableError.notFound("PATH environment variable not found")
  }

  let paths = path.split(separator: ":").map(String.init)
  for dir in paths {
    let fullPath = "\(dir)/\(name)"
    if FileManager.default.isExecutableFile(atPath: fullPath) {
      return fullPath
    }
  }

  throw ExecutableError.notFound("\(name) not found in PATH")
}

func formatFrameworks(_ frameworks: [FrameworkInfo]) throws -> String {
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
  guard let jsonString = String(data: try encoder.encode(frameworks), encoding: .utf8) else {
    throw NSError(
      domain: "StringConversionError", code: 1,
      userInfo: [
        NSLocalizedDescriptionKey: "Failed to convert JSON data to a UTF-8 string"
      ]
    )
  }
  return jsonString
}

// Main execution flow
let (frameworkPaths, outputPath, verbose) = parseArguments()

let frameworks = try frameworkPaths.map { try determineArchitectureAndPlatform(for: $0) }
if verbose {
  print("## Frameworks\n")
  print(try formatFrameworks(frameworks))
}

let plistData = try generateInfoPlistData(for: frameworks)
if verbose {
  print("\n## Info.plist\n")
  print(try formatPlistData(plistData))
}

try createXCFrameworkStructure(
  outputPath: outputPath,
  frameworks: frameworks,
  plistData: plistData
)
if verbose {
  print("xcframework successfully written out to: \(outputPath)")
}
