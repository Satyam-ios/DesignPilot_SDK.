import Foundation
import DesignPilotSDK

/// Manages non-destructive staging, conflict detection, and atomic file integration.
public struct SafeFileIntegrator: Sendable {
    private var fileManager: FileManager { FileManager.default }
    private let snapshotManager = RollbackSnapshotManager()

    public init() {}

    /// Stages generated source files in an isolated staging workspace `.designpilot/staging/`.
    public func stageFiles(
        files: [GeneratedFile],
        projectRoot: String = FileManager.default.currentDirectoryPath
    ) throws -> [GeneratedFile] {
        let stagingRootURL = URL(fileURLWithPath: projectRoot)
            .appendingPathComponent(".designpilot/staging")

        try fileManager.createDirectory(at: stagingRootURL, withIntermediateDirectories: true)

        var inspectedFiles: [GeneratedFile] = []

        for file in files {
            // Write to staging area
            let stagedFileURL = stagingRootURL.appendingPathComponent(file.relativePath)
            let parentDir = stagedFileURL.deletingLastPathComponent()
            try fileManager.createDirectory(at: parentDir, withIntermediateDirectories: true)
            try file.content.data(using: .utf8)?.write(to: stagedFileURL)

            // Check destination conflict
            let targetFileURL = URL(fileURLWithPath: projectRoot).appendingPathComponent(file.relativePath)
            var status: FileChangeStatus = .created
            var existingContent: String? = nil

            if fileManager.fileExists(atPath: targetFileURL.path) {
                if let old = try? String(contentsOf: targetFileURL, encoding: .utf8) {
                    existingContent = old
                    status = (old == file.content) ? .unchanged : .modified
                } else {
                    status = .modified
                }
            }

            inspectedFiles.append(
                GeneratedFile(
                    relativePath: file.relativePath,
                    content: file.content,
                    status: status,
                    framework: file.framework,
                    existingContent: existingContent
                )
            )
        }

        return inspectedFiles
    }

    /// Safely commits staged files into the target Xcode project after creating a backup snapshot.
    public func commit(
        selectedFilePaths: [String],
        projectRoot: String = FileManager.default.currentDirectoryPath,
        createBackup: Bool = true
    ) throws -> IntegrationSummary {
        let rootURL = URL(fileURLWithPath: projectRoot)
        let stagingURL = rootURL.appendingPathComponent(".designpilot/staging")

        var addedList: [String] = []
        var modifiedList: [String] = []

        // Backup existing destination files before writing
        var backupId = "none"
        if createBackup {
            backupId = try snapshotManager.createSnapshot(
                baseDirectory: projectRoot,
                filesToBackup: selectedFilePaths
            )
        }

        // Commit selected files
        for relPath in selectedFilePaths {
            let stagedFile = stagingURL.appendingPathComponent(relPath)
            let destinationFile = rootURL.appendingPathComponent(relPath)

            guard fileManager.fileExists(atPath: stagedFile.path) else {
                continue
            }

            let isExisting = fileManager.fileExists(atPath: destinationFile.path)
            let parentDir = destinationFile.deletingLastPathComponent()
            try fileManager.createDirectory(at: parentDir, withIntermediateDirectories: true)

            if isExisting {
                try fileManager.removeItem(at: destinationFile)
                modifiedList.append(relPath)
            } else {
                addedList.append(relPath)
            }

            try fileManager.copyItem(at: stagedFile, to: destinationFile)
        }

        if createBackup && backupId != "none" {
            try? snapshotManager.recordCreatedFiles(
                baseDirectory: projectRoot,
                backupId: backupId,
                newFilesCreated: addedList
            )
        }

        return IntegrationSummary(
            backupId: backupId,
            backupPath: ".designpilot/backups/\(backupId)",
            addedFiles: addedList,
            modifiedFiles: modifiedList,
            preservedFiles: [],
            targetDirectory: projectRoot
        )
    }

    /// Restores a previously created backup snapshot.
    public func rollback(
        backupId: String,
        projectRoot: String = FileManager.default.currentDirectoryPath
    ) throws -> Bool {
        return try snapshotManager.restore(baseDirectory: projectRoot, backupId: backupId)
    }
}
