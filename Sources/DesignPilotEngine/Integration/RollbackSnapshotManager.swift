import Foundation
import DesignPilotSDK

/// Manages atomic backup snapshots and rollbacks for project file integrations.
public struct RollbackSnapshotManager: Sendable {
    private var fileManager: FileManager { FileManager.default }

    public init() {}

    /// Creates an atomic snapshot backup of files before they are modified or overwritten.
    public func createSnapshot(
        baseDirectory: String,
        filesToBackup: [String],
        newFilesCreated: [String] = []
    ) throws -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let backupId = "backup_\(timestamp)"
        let backupDirURL = URL(fileURLWithPath: baseDirectory)
            .appendingPathComponent(".designpilot/backups/\(backupId)")

        try fileManager.createDirectory(at: backupDirURL, withIntermediateDirectories: true)

        var backedUpFiles: [String] = []

        for relPath in filesToBackup {
            let originalURL = URL(fileURLWithPath: baseDirectory).appendingPathComponent(relPath)
            if fileManager.fileExists(atPath: originalURL.path) {
                let destinationURL = backupDirURL.appendingPathComponent(relPath)
                let parentDir = destinationURL.deletingLastPathComponent()
                try fileManager.createDirectory(at: parentDir, withIntermediateDirectories: true)
                try fileManager.copyItem(at: originalURL, to: destinationURL)
                backedUpFiles.append(relPath)
            }
        }

        // Write snapshot metadata
        let metadata = SnapshotMetadata(
            backupId: backupId,
            timestamp: Date(),
            files: backedUpFiles,
            newFilesCreated: newFilesCreated,
            baseDirectory: baseDirectory
        )
        let metaURL = backupDirURL.appendingPathComponent("snapshot_meta.json")
        let data = try JSONEncoder().encode(metadata)
        try data.write(to: metaURL)

        return backupId
    }

    /// Updates existing snapshot metadata with newly created files list.
    public func recordCreatedFiles(
        baseDirectory: String,
        backupId: String,
        newFilesCreated: [String]
    ) throws {
        let backupDirURL = URL(fileURLWithPath: baseDirectory)
            .appendingPathComponent(".designpilot/backups/\(backupId)")
        let metaURL = backupDirURL.appendingPathComponent("snapshot_meta.json")

        if let data = try? Data(contentsOf: metaURL),
           var metadata = try? JSONDecoder().decode(SnapshotMetadata.self, from: data) {
            metadata.newFilesCreated = newFilesCreated
            let updatedData = try JSONEncoder().encode(metadata)
            try updatedData.write(to: metaURL)
        }
    }

    /// Restores a previous snapshot by backup ID.
    public func restore(
        baseDirectory: String,
        backupId: String
    ) throws -> Bool {
        let backupDirURL = URL(fileURLWithPath: baseDirectory)
            .appendingPathComponent(".designpilot/backups/\(backupId)")

        let metaURL = backupDirURL.appendingPathComponent("snapshot_meta.json")
        guard let data = try? Data(contentsOf: metaURL),
              let metadata = try? JSONDecoder().decode(SnapshotMetadata.self, from: data) else {
            throw DesignPilotError.rollbackFailed(reason: "Metadata not found for backup \(backupId)")
        }

        // 1. Remove newly created files
        for relPath in metadata.newFilesCreated {
            let targetFileURL = URL(fileURLWithPath: baseDirectory).appendingPathComponent(relPath)
            if fileManager.fileExists(atPath: targetFileURL.path) {
                try fileManager.removeItem(at: targetFileURL)
            }
        }

        // 2. Restore modified / backed up files
        for relPath in metadata.files {
            let backupFileURL = backupDirURL.appendingPathComponent(relPath)
            let targetFileURL = URL(fileURLWithPath: baseDirectory).appendingPathComponent(relPath)

            if fileManager.fileExists(atPath: backupFileURL.path) {
                if fileManager.fileExists(atPath: targetFileURL.path) {
                    try fileManager.removeItem(at: targetFileURL)
                }
                let parent = targetFileURL.deletingLastPathComponent()
                try fileManager.createDirectory(at: parent, withIntermediateDirectories: true)
                try fileManager.copyItem(at: backupFileURL, to: targetFileURL)
            }
        }

        return true
    }
}

public struct SnapshotMetadata: Codable, Sendable {
    public let backupId: String
    public let timestamp: Date
    public let files: [String]
    public var newFilesCreated: [String]
    public let baseDirectory: String

    public init(
        backupId: String,
        timestamp: Date,
        files: [String],
        newFilesCreated: [String] = [],
        baseDirectory: String
    ) {
        self.backupId = backupId
        self.timestamp = timestamp
        self.files = files
        self.newFilesCreated = newFilesCreated
        self.baseDirectory = baseDirectory
    }
}
