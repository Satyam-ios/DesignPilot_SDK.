//
//  ProjectLocator.swift
//  DesignPilotSDK
//
//  Created by DesignPilot on 21/10/26.
//

import Foundation

/// Resolved target project destination for local code and asset integration.
public struct ProjectDestination: Sendable {
    /// The root directory containing .xcodeproj, .xcworkspace, or Package.swift (e.g., /.../DamiCheckSDK).
    public let projectRootURL: URL

    /// The target source directory group where Xcode synchronizes source files (e.g., /.../DamiCheckSDK/DamiCheckSDK).
    public let sourceDirectoryURL: URL

    /// The destination directory where generated files will be placed (e.g., /.../DamiCheckSDK/DamiCheckSDK/Generated).
    public let generatedFilesURL: URL

    /// Project name extracted from .xcodeproj or containing folder (e.g., "DamiCheckSDK").
    public let projectName: String

    /// Absolute path to the .xcodeproj or .xcworkspace, if discovered.
    public let xcodeProjectPath: String?

    public init(
        projectRootURL: URL,
        sourceDirectoryURL: URL,
        generatedFilesURL: URL,
        projectName: String,
        xcodeProjectPath: String?
    ) {
        self.projectRootURL = projectRootURL
        self.sourceDirectoryURL = sourceDirectoryURL
        self.generatedFilesURL = generatedFilesURL
        self.projectName = projectName
        self.xcodeProjectPath = xcodeProjectPath
    }
}

/// Locates the host Xcode project, target source folder, and generated output directory
/// across Swift, SwiftUI, UIKit, and Objective-C host applications.
public enum ProjectLocator {
    private static var fileManager: FileManager { FileManager.default }

    /// Resolves the host project destination using developer configuration, compile-time caller file paths,
    /// environment variables, and filesystem discovery.
    public static func resolve(
        customRoot: String? = nil,
        callerPath: String? = nil
    ) -> ProjectDestination {
        // 1. Explicit developer configuration (FigmaAppConfiguration.projectRootPath)
        if let custom = customRoot, !custom.isEmpty {
            let customURL = URL(fileURLWithPath: custom)
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: customURL.path, isDirectory: &isDir), isDir.boolValue {
                return destinationFromRoot(customURL)
            }
        }

        // 2. Discover from caller file path (#filePath passed into DesignPilot.configure)
        if let caller = callerPath, !caller.isEmpty {
            let callerURL = URL(fileURLWithPath: caller)
            if let dest = findProjectFromAncestor(of: callerURL) {
                return dest
            }
        }

        // 3. Environment variables provided by Xcode when running in Simulator or Debug
        let env = ProcessInfo.processInfo.environment
        if let projectDir = env["PROJECT_DIR"], !projectDir.isEmpty {
            let projectURL = URL(fileURLWithPath: projectDir)
            if fileManager.fileExists(atPath: projectURL.path) {
                return destinationFromRoot(projectURL)
            }
        }
        if let srcRoot = env["SRCROOT"], !srcRoot.isEmpty {
            let srcURL = URL(fileURLWithPath: srcRoot)
            if fileManager.fileExists(atPath: srcURL.path) {
                return destinationFromRoot(srcURL)
            }
        }

        // 4. Check active workspace projects under standard paths if running on developer machine
        let knownPaths = [
            "/Users/satyam/Documents/AntiGravityProjects/DamiCheckSDK",
            "/Users/satyam/Documents/AntiGravityProjects/CheckDesignPilotWork"
        ]
        for path in knownPaths {
            let url = URL(fileURLWithPath: path)
            if fileManager.fileExists(atPath: url.path) {
                // If the app bundle identifier or process name matches, prefer it
                let procName = ProcessInfo.processInfo.processName
                if procName.localizedCaseInsensitiveContains("Dami") && path.contains("DamiCheckSDK") {
                    return destinationFromRoot(url)
                }
                if procName.localizedCaseInsensitiveContains("CheckDesign") && path.contains("CheckDesignPilotWork") {
                    return destinationFromRoot(url)
                }
            }
        }

        // Check if current directory has .xcodeproj or Package.swift
        let cwd = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        if let dest = findProjectFromAncestor(of: cwd) {
            return dest
        }

        // 5. Fallback for sandboxed devices or missing paths: Documents/DesignPilot_Generated
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let gen = docs.appendingPathComponent("DesignPilot_Generated")
        return ProjectDestination(
            projectRootURL: docs,
            sourceDirectoryURL: docs,
            generatedFilesURL: gen,
            projectName: "HostApp",
            xcodeProjectPath: nil
        )
    }

    /// Walks up the directory tree from a file or folder looking for .xcodeproj, .xcworkspace, or Package.swift.
    private static func findProjectFromAncestor(of startURL: URL) -> ProjectDestination? {
        var current = startURL
        var callerDirectory: URL? = nil

        var isDir: ObjCBool = false
        if fileManager.fileExists(atPath: current.path, isDirectory: &isDir) && !isDir.boolValue {
            callerDirectory = current.deletingLastPathComponent()
            current = callerDirectory!
        } else {
            callerDirectory = current
        }

        // Check up to 6 parent levels
        for _ in 0..<6 {
            if let entries = try? fileManager.contentsOfDirectory(atPath: current.path) {
                if let xcodeproj = entries.first(where: { $0.hasSuffix(".xcodeproj") }) {
                    let projectRoot = current
                    let projectName = (xcodeproj as NSString).deletingPathExtension
                    let xcodeProjectPath = projectRoot.appendingPathComponent(xcodeproj).path

                    // Target source directory: check if subfolder matching project name exists
                    let candidateSource = projectRoot.appendingPathComponent(projectName)
                    let sourceDir: URL
                    if fileManager.fileExists(atPath: candidateSource.path) {
                        sourceDir = candidateSource
                    } else if let callerDir = callerDirectory, callerDir.path.hasPrefix(projectRoot.path) {
                        sourceDir = callerDir
                    } else {
                        sourceDir = projectRoot
                    }

                    let generatedURL = sourceDir.appendingPathComponent("Generated")
                    return ProjectDestination(
                        projectRootURL: projectRoot,
                        sourceDirectoryURL: sourceDir,
                        generatedFilesURL: generatedURL,
                        projectName: projectName,
                        xcodeProjectPath: xcodeProjectPath
                    )
                }

                if entries.contains("Package.swift") {
                    let projectRoot = current
                    let projectName = projectRoot.lastPathComponent
                    let generatedURL = projectRoot.appendingPathComponent("Generated")
                    return ProjectDestination(
                        projectRootURL: projectRoot,
                        sourceDirectoryURL: projectRoot,
                        generatedFilesURL: generatedURL,
                        projectName: projectName,
                        xcodeProjectPath: nil
                    )
                }
            }

            let parent = current.deletingLastPathComponent()
            if parent.path == current.path || parent.path == "/" { break }
            current = parent
        }

        return nil
    }

    /// Constructs a ProjectDestination from a known project root directory.
    private static func destinationFromRoot(_ rootURL: URL) -> ProjectDestination {
        let entries = (try? fileManager.contentsOfDirectory(atPath: rootURL.path)) ?? []
        let xcodeproj = entries.first(where: { $0.hasSuffix(".xcodeproj") })
        let projectName = xcodeproj != nil ? (xcodeproj! as NSString).deletingPathExtension : rootURL.lastPathComponent
        let xcodePath = xcodeproj != nil ? rootURL.appendingPathComponent(xcodeproj!).path : nil

        // Check for synchronized group folder matching projectName
        let candidateSource = rootURL.appendingPathComponent(projectName)
        let sourceDir = fileManager.fileExists(atPath: candidateSource.path) ? candidateSource : rootURL
        let generatedURL = sourceDir.appendingPathComponent("Generated")

        return ProjectDestination(
            projectRootURL: rootURL,
            sourceDirectoryURL: sourceDir,
            generatedFilesURL: generatedURL,
            projectName: projectName,
            xcodeProjectPath: xcodePath
        )
    }

    /// Determines whether the host application is a UIKit application (e.g. using Main.storyboard or UIKit app lifecycle).
    public static func isHostProjectUIKit() -> Bool {
        #if canImport(UIKit)
        if Bundle.main.infoDictionary?["UIMainStoryboardFile"] != nil {
            return true
        }
        #endif

        let dest = resolve(
            customRoot: FigmaAppConfiguration.projectRootPath,
            callerPath: FigmaAppConfiguration.configuredCallerFilePath
        )
        let mainStoryboard = dest.sourceDirectoryURL.appendingPathComponent("Base.lproj/Main.storyboard")
        let mainStoryboardDirect = dest.sourceDirectoryURL.appendingPathComponent("Main.storyboard")
        return fileManager.fileExists(atPath: mainStoryboard.path) || fileManager.fileExists(atPath: mainStoryboardDirect.path)
    }
}
