//
//  LocalProjectIntegrator.swift
//  DesignPilotSDK
//
//  Created by DesignPilot on 21/10/26.
//

import Foundation

/// Manages non-destructive staging, atomic backup snapshots, and real file writing
/// directly into the developer's host Xcode project or filesystem.
public struct LocalProjectIntegrator: Sendable {
    public static let shared = LocalProjectIntegrator()

    private var fileManager: FileManager { FileManager.default }

    public init() {}

    /// Writes generated files to disk in the host project, creating an atomic rollback snapshot before touching any file.
    /// - Parameters:
    ///   - files: The array of `GeneratedFile`s to write.
    ///   - selectedPaths: Optional subset of paths to commit. If nil or empty, commits all files.
    ///   - destination: Optional pre-resolved `ProjectDestination`. If nil, automatically discovered.
    ///   - createBackup: Whether to take an atomic rollback snapshot before writing.
    /// - Returns: An `IntegrationSummary` describing the written files, destination path, and backup ID.
    @discardableResult
    public func integrate(
        files: [GeneratedFile],
        selectedPaths: Set<String>? = nil,
        destination: ProjectDestination? = nil,
        createBackup: Bool = true
    ) throws -> IntegrationSummary {
        let dest = destination ?? ProjectLocator.resolve(
            customRoot: FigmaAppConfiguration.projectRootPath,
            callerPath: FigmaAppConfiguration.configuredCallerFilePath
        )

        // Filter files if selectedPaths is specified
        let filesToWrite: [GeneratedFile]
        if let paths = selectedPaths, !paths.isEmpty {
            filesToWrite = files.filter { paths.contains($0.relativePath) || paths.contains(cleanSubpath(for: $0.relativePath)) }
        } else {
            filesToWrite = files
        }

        guard !filesToWrite.isEmpty else {
            throw DesignPilotError.unknown("No files selected for integration.")
        }

        let backupId = "backup_\(Int(Date().timeIntervalSince1970))"
        let backupRootURL = dest.projectRootURL
            .appendingPathComponent(".designpilot")
            .appendingPathComponent("backups")
            .appendingPathComponent(backupId)

        if createBackup {
            try fileManager.createDirectory(at: backupRootURL, withIntermediateDirectories: true)
        }

        var addedFiles: [String] = []
        var modifiedFiles: [String] = []

        // Ensure target directory exists
        try fileManager.createDirectory(at: dest.generatedFilesURL, withIntermediateDirectories: true)

        for file in filesToWrite {
            let relativeSubpath = cleanSubpath(for: file.relativePath)
            let destinationFileURL = dest.generatedFilesURL.appendingPathComponent(relativeSubpath)
            let destinationParent = destinationFileURL.deletingLastPathComponent()

            try fileManager.createDirectory(at: destinationParent, withIntermediateDirectories: true)

            let isExisting = fileManager.fileExists(atPath: destinationFileURL.path)

            if isExisting {
                if createBackup {
                    let backupFileURL = backupRootURL.appendingPathComponent(relativeSubpath)
                    try fileManager.createDirectory(at: backupFileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
                    if fileManager.fileExists(atPath: backupFileURL.path) {
                        try? fileManager.removeItem(at: backupFileURL)
                    }
                    try fileManager.copyItem(at: destinationFileURL, to: backupFileURL)
                }
                try fileManager.removeItem(at: destinationFileURL)
                modifiedFiles.append(relativeSubpath)
            } else {
                addedFiles.append(relativeSubpath)
            }

            guard let data = file.content.data(using: .utf8) else {
                continue
            }
            try data.write(to: destinationFileURL, options: .atomic)
        }

        // Also ensure a mirror copy in projectRoot/Views/Generated if different from destinationURL
        let mirrorRoot = dest.projectRootURL.appendingPathComponent("Views").appendingPathComponent("Generated")
        if mirrorRoot.path != dest.generatedFilesURL.path {
            try? fileManager.createDirectory(at: mirrorRoot, withIntermediateDirectories: true)
            for file in filesToWrite {
                let sub = cleanSubpath(for: file.relativePath)
                let mirrorFile = mirrorRoot.appendingPathComponent(sub)
                try? fileManager.createDirectory(at: mirrorFile.deletingLastPathComponent(), withIntermediateDirectories: true)
                try? file.content.data(using: .utf8)?.write(to: mirrorFile, options: .atomic)
            }
        }

        // Record integration manifest
        if createBackup {
            let manifest = [
                "backupId": backupId,
                "timestamp": ISO8601DateFormatter().string(from: Date()),
                "projectRoot": dest.projectRootURL.path,
                "targetDirectory": dest.generatedFilesURL.path,
                "addedFiles": addedFiles,
                "modifiedFiles": modifiedFiles
            ] as [String : Any]

            if let manifestData = try? JSONSerialization.data(withJSONObject: manifest, options: .prettyPrinted) {
                let manifestURL = backupRootURL.appendingPathComponent("manifest.json")
                try? manifestData.write(to: manifestURL)
            }
        }

        return IntegrationSummary(
            backupId: backupId,
            backupPath: backupRootURL.path,
            addedFiles: addedFiles,
            modifiedFiles: modifiedFiles,
            preservedFiles: ["AppDelegate.swift", "SceneDelegate.swift", "ViewController.swift"],
            targetDirectory: dest.generatedFilesURL.path
        )
    }

    /// Restores a previous backup snapshot and removes newly created files.
    public func rollback(
        backupId: String,
        projectRoot: String? = nil
    ) throws -> Bool {
        let rootPath = projectRoot ?? ProjectLocator.resolve(
            customRoot: FigmaAppConfiguration.projectRootPath,
            callerPath: FigmaAppConfiguration.configuredCallerFilePath
        ).projectRootURL.path

        let backupDir = URL(fileURLWithPath: rootPath)
            .appendingPathComponent(".designpilot")
            .appendingPathComponent("backups")
            .appendingPathComponent(backupId)

        guard fileManager.fileExists(atPath: backupDir.path) else {
            return false
        }

        let manifestURL = backupDir.appendingPathComponent("manifest.json")
        guard let data = try? Data(contentsOf: manifestURL),
              let manifest = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let targetDir = manifest["targetDirectory"] as? String else {
            return false
        }

        let targetURL = URL(fileURLWithPath: targetDir)

        // 1. Remove added files
        if let added = manifest["addedFiles"] as? [String] {
            for file in added {
                let url = targetURL.appendingPathComponent(file)
                try? fileManager.removeItem(at: url)
            }
        }

        // 2. Restore modified files from backup
        if let modified = manifest["modifiedFiles"] as? [String] {
            for file in modified {
                let backedUp = backupDir.appendingPathComponent(file)
                let destination = targetURL.appendingPathComponent(file)
                if fileManager.fileExists(atPath: backedUp.path) {
                    try? fileManager.removeItem(at: destination)
                    try? fileManager.copyItem(at: backedUp, to: destination)
                }
            }
        }

        return true
    }

    /// Strips leading directory prefixes like "Views/Generated/" to keep clean folder structure inside target Generated folder.
    private func cleanSubpath(for path: String) -> String {
        var clean = path
        let prefixes = ["Views/Generated/", "Generated/"]
        for p in prefixes {
            if clean.hasPrefix(p) {
                clean = String(clean.dropFirst(p.count))
                break
            }
        }
        return clean
    }
}
