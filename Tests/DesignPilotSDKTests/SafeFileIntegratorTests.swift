import XCTest
@testable import DesignPilotSDK
@testable import DesignPilotEngine

final class SafeFileIntegratorTests: XCTestCase {
    var tempDirectory: URL!

    override func setUpWithError() throws {
        let temp = FileManager.default.temporaryDirectory
            .appendingPathComponent("DesignPilotTests_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true)
        self.tempDirectory = temp
    }

    override func tearDownWithError() throws {
        if let temp = tempDirectory {
            try? FileManager.default.removeItem(at: temp)
        }
    }

    func testStagingAndConflictDetection() throws {
        let integrator = SafeFileIntegrator()

        // Create an existing file to test conflict
        let existingPath = "Views/ExistingView.swift"
        let fullExistingURL = tempDirectory.appendingPathComponent(existingPath)
        try FileManager.default.createDirectory(at: fullExistingURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try "Original Content".write(to: fullExistingURL, atomically: true, encoding: .utf8)

        let filesToStage = [
            GeneratedFile(
                relativePath: existingPath,
                content: "Updated Content",
                status: .created,
                framework: .swiftUI
            ),
            GeneratedFile(
                relativePath: "Views/BrandNewView.swift",
                content: "New View Content",
                status: .created,
                framework: .swiftUI
            )
        ]

        let inspected = try integrator.stageFiles(files: filesToStage, projectRoot: tempDirectory.path)

        XCTAssertEqual(inspected.count, 2)
        let conflictFile = inspected.first(where: { $0.relativePath == existingPath })
        XCTAssertEqual(conflictFile?.status, .modified)
        XCTAssertEqual(conflictFile?.existingContent, "Original Content")

        let newFile = inspected.first(where: { $0.relativePath == "Views/BrandNewView.swift" })
        XCTAssertEqual(newFile?.status, .created)
    }

    func testCommitAndRollback() throws {
        let integrator = SafeFileIntegrator()

        let targetRelPath = "Views/TargetScreen.swift"
        let targetFileURL = tempDirectory.appendingPathComponent(targetRelPath)
        try FileManager.default.createDirectory(at: targetFileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try "Version 1.0 Code".write(to: targetFileURL, atomically: true, encoding: .utf8)

        // Stage version 2.0
        let staged = try integrator.stageFiles(
            files: [GeneratedFile(relativePath: targetRelPath, content: "Version 2.0 Code", status: .created, framework: .swiftUI)],
            projectRoot: tempDirectory.path
        )
        XCTAssertEqual(staged.first?.status, .modified)

        // Commit version 2.0
        let summary = try integrator.commit(
            selectedFilePaths: [targetRelPath],
            projectRoot: tempDirectory.path,
            createBackup: true
        )

        let postCommitContent = try String(contentsOf: targetFileURL, encoding: .utf8)
        XCTAssertEqual(postCommitContent, "Version 2.0 Code")
        XCTAssertFalse(summary.backupId.isEmpty)

        // Roll back
        let rollbackSuccess = try integrator.rollback(backupId: summary.backupId, projectRoot: tempDirectory.path)
        XCTAssertTrue(rollbackSuccess)

        let postRollbackContent = try String(contentsOf: targetFileURL, encoding: .utf8)
        XCTAssertEqual(postRollbackContent, "Version 1.0 Code")
    }
}
