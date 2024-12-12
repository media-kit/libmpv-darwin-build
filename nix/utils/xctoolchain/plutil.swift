// A lightweight clone of `plutil`` implementing the conversion of a plist file
// from XML format to binary format, used during the creation of a framework.
// This clone exists because Xcode.app does not include it, and the versions of
// `plutil` contained in the packages provided by Nix are no longer maintained.

import Foundation

func convertPlist(to format: String, plistPath: String) {
  // Check if the specified format is "binary1"
  guard format == "binary1" else {
    print("Unsupported format. Use 'binary1'")
    return
  }

  // Load plist data from the given path
  guard let plistData = FileManager.default.contents(atPath: plistPath) else {
    print("Error: File not found at \(plistPath)")
    return
  }

  var plistFormat = PropertyListSerialization.PropertyListFormat.xml
  do {
    // Deserialize the plist file
    let plistObject = try PropertyListSerialization.propertyList(
      from: plistData, options: [], format: &plistFormat
    )

    // Serialize back to binary format
    let binaryData = try PropertyListSerialization.data(
      fromPropertyList: plistObject, format: .binary, options: 0
    )

    // Overwrite the original file with the binary version
    try binaryData.write(to: URL(fileURLWithPath: plistPath))
  } catch {
    print("Error during conversion: \(error)")
  }
}

let arguments = CommandLine.arguments
if arguments.count == 4, arguments[1] == "-convert" {
  let format = arguments[2]
  let plistPath = arguments[3]
  convertPlist(to: format, plistPath: plistPath)
} else {
  print("Usage: plutil -convert binary1 /path/to/Info.plist")
}
