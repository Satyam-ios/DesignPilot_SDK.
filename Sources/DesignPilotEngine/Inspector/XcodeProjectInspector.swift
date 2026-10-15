import Foundation
import DesignPilotSDK

/// Analyzes the target iOS Xcode project to guide adaptive code generation.
public struct XcodeProjectInspector: Sendable {
    private var fileManager: FileManager { FileManager.default }

    public init() {}

    /// Inspects the project located at `projectPath` (or current working directory).
    public func inspect(projectPath: String = FileManager.default.currentDirectoryPath) throws -> ProjectArchitecture {
        let url = URL(fileURLWithPath: projectPath)
        let contents = try? fileManager.contentsOfDirectory(atPath: projectPath)

        let xcodeProjName = contents?.first(where: { $0.hasSuffix(".xcodeproj") })
        let projectName = xcodeProjName?.replacingOccurrences(of: ".xcodeproj", with: "")
            ?? url.lastPathComponent

        var minDeployment = "16.0"
        var swiftVer = "6.0"
        var viewsDir: String? = nil
        var assetCatalogs: [String] = []

        // Search for .pbxproj
        if let proj = xcodeProjName {
            let pbxPath = url.appendingPathComponent("\(proj)/project.pbxproj").path
            if let pbxContent = try? String(contentsOfFile: pbxPath, encoding: .utf8) {
                // Parse deployment target
                if let targetMatch = extractPBXValue(key: "IPHONEOS_DEPLOYMENT_TARGET", in: pbxContent) {
                    minDeployment = targetMatch
                }
                // Parse Swift version
                if let swiftMatch = extractPBXValue(key: "SWIFT_VERSION", in: pbxContent) {
                    swiftVer = swiftMatch
                }
            }
        } else if let packageSwift = try? String(contentsOf: url.appendingPathComponent("Package.swift"), encoding: .utf8) {
            if packageSwift.contains(".iOS(.v17)") { minDeployment = "17.0" }
            else if packageSwift.contains(".iOS(.v16)") { minDeployment = "16.0" }
            else if packageSwift.contains(".iOS(.v15)") { minDeployment = "15.0" }
        }

        // Scan for existing view folders
        let potentialViewFolders = ["Views", "Screens", "UI", "Components", "Source/Views"]
        for folder in potentialViewFolders {
            let folderURL = url.appendingPathComponent(folder)
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: folderURL.path, isDirectory: &isDir), isDir.boolValue {
                viewsDir = folder
                break
            }
        }

        // Scan for asset catalogs
        if let enumerator = fileManager.enumerator(atPath: projectPath) {
            for case let path as String in enumerator {
                if path.hasSuffix(".xcassets") {
                    assetCatalogs.append(path)
                }
            }
        }

        var detectedFramework: ProjectUIFramework = .swiftUI

        // Scan Swift and Interface Builder files in project to detect framework
        if let enumerator = fileManager.enumerator(atPath: projectPath) {
            var uiKitCount = 0
            var swiftUICount = 0
            for case let relativeFile as String in enumerator {
                if relativeFile.contains(".build") || relativeFile.contains(".git") || relativeFile.contains(".swiftpm") {
                    continue
                }
                if relativeFile.hasSuffix(".swift") {
                    let fileURL = url.appendingPathComponent(relativeFile)
                    if let code = try? String(contentsOf: fileURL, encoding: .utf8) {
                        if code.contains("import SwiftUI") || code.contains(": View") || code.contains(": App") {
                            swiftUICount += 1
                        }
                        if code.contains("UIViewController") || code.contains("UIApplicationDelegate") {
                            uiKitCount += 1
                        }
                    }
                } else if relativeFile.hasSuffix(".storyboard") || relativeFile.hasSuffix(".xib") {
                    uiKitCount += 2
                }
            }
            if uiKitCount > 0 && swiftUICount == 0 {
                detectedFramework = .uiKit
            }
        }

        // Query available simulators
        let simulators = queryAvailableSimulators()

        return ProjectArchitecture(
            projectName: projectName,
            projectRootPath: projectPath,
            minDeploymentTarget: minDeployment,
            swiftVersion: swiftVer,
            primaryFramework: detectedFramework,
            existingViewsDirectory: viewsDir,
            assetCatalogPaths: assetCatalogs,
            supportedDeviceFamilies: ["iPhone", "iPad"],
            availableSimulators: simulators
        )
    }

    private func extractPBXValue(key: String, in content: String) -> String? {
        let pattern = "\(key)\\s*=\\s*([^;]+);"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(content.startIndex..<content.endIndex, in: content)
        if let match = regex.firstMatch(in: content, range: range),
           let valRange = Range(match.range(at: 1), in: content) {
            return String(content[valRange]).trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
        }
        return nil
    }

    private func queryAvailableSimulators() -> [DiscoveredSimulator] {
        #if os(macOS)
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["simctl", "list", "devices", "available", "--json"]
        process.standardOutput = pipe

        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()

            struct SimOutput: Decodable {
                let devices: [String: [SimDevice]]
            }
            struct SimDevice: Decodable {
                let name: String
                let udid: String
                let isAvailable: Bool
            }

            if let decoded = try? JSONDecoder().decode(SimOutput.self, from: data) {
                var list: [DiscoveredSimulator] = []
                for (runtime, devices) in decoded.devices where runtime.contains("iOS") {
                    for dev in devices where dev.name.contains("iPhone") || dev.name.contains("iPad") {
                        list.append(DiscoveredSimulator(name: dev.name, udid: dev.udid, osVersion: runtime, isAvailable: dev.isAvailable))
                    }
                }
                if !list.isEmpty {
                    return Array(list.prefix(8))
                }
            }
        } catch {}
        #endif

        // Standard default simulators
        return [
            DiscoveredSimulator(name: "iPhone 16 Pro", udid: "sim-ip16pro", osVersion: "iOS 18.0"),
            DiscoveredSimulator(name: "iPhone SE (3rd generation)", udid: "sim-ipse", osVersion: "iOS 18.0"),
            DiscoveredSimulator(name: "iPad Air (11-inch)", udid: "sim-ipadair", osVersion: "iOS 18.0")
        ]
    }
}
