//
//  LocalProjectIntegratorTests.swift
//  DesignPilotSDKTests
//
//  Created by DesignPilot on 21/10/26.
//

import XCTest
@testable import DesignPilotSDK

final class LocalProjectIntegratorTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("DesignPilotTest_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }

    func testProjectLocatorResolvesCustomRoot() {
        let dummyProj = tempDirectory.appendingPathComponent("SampleApp.xcodeproj")
        try? "dummy".write(to: dummyProj, atomically: true, encoding: .utf8)
        let srcDir = tempDirectory.appendingPathComponent("SampleApp")
        try? FileManager.default.createDirectory(at: srcDir, withIntermediateDirectories: true)

        let dest = ProjectLocator.resolve(customRoot: tempDirectory.path)
        XCTAssertEqual(dest.projectRootURL.path, tempDirectory.path)
        XCTAssertEqual(dest.sourceDirectoryURL.path, srcDir.path)
        XCTAssertEqual(dest.generatedFilesURL.path, srcDir.appendingPathComponent("Generated").path)
        XCTAssertEqual(dest.projectName, "SampleApp")
    }

    func testLocalProjectIntegratorWritesRealFilesToDisk() throws {
        let dummyProj = tempDirectory.appendingPathComponent("DummyApp.xcodeproj")
        try? "dummy".write(to: dummyProj, atomically: true, encoding: .utf8)
        let srcDir = tempDirectory.appendingPathComponent("DummyApp")
        try? FileManager.default.createDirectory(at: srcDir, withIntermediateDirectories: true)

        let dest = ProjectLocator.resolve(customRoot: tempDirectory.path)

        let files = [
            GeneratedFile(
                relativePath: "Views/Generated/UIKit/HomeDailyTargetViewController.swift",
                content: "// Test Content for Home VC",
                status: .created,
                framework: .uiKit
            ),
            GeneratedFile(
                relativePath: "Views/Generated/Storyboards/Main.storyboard",
                content: "<?xml version=\"1.0\"?><document></document>",
                status: .created,
                framework: .uiKit
            )
        ]

        let summary = try LocalProjectIntegrator.shared.integrate(
            files: files,
            destination: dest,
            createBackup: true
        )

        XCTAssertEqual(summary.addedFiles.count, 2)

        // Verify files actually exist on disk in dest.generatedFilesURL
        let homeFile = dest.generatedFilesURL.appendingPathComponent("UIKit/HomeDailyTargetViewController.swift")
        let storyboardFile = dest.generatedFilesURL.appendingPathComponent("Storyboards/Main.storyboard")

        XCTAssertTrue(FileManager.default.fileExists(atPath: homeFile.path), "Home VC file must exist on disk")
        XCTAssertTrue(FileManager.default.fileExists(atPath: storyboardFile.path), "Storyboard file must exist on disk")

        let homeContent = try String(contentsOf: homeFile, encoding: .utf8)
        XCTAssertEqual(homeContent, "// Test Content for Home VC")
    }

    func testLocalProjectIntegratorRollbackRestoresPreviousState() throws {
        let dummyProj = tempDirectory.appendingPathComponent("RollbackApp.xcodeproj")
        try? "dummy".write(to: dummyProj, atomically: true, encoding: .utf8)
        let srcDir = tempDirectory.appendingPathComponent("RollbackApp")
        let genDir = srcDir.appendingPathComponent("Generated")
        try? FileManager.default.createDirectory(at: genDir.appendingPathComponent("Views"), withIntermediateDirectories: true)

        let existingFile = genDir.appendingPathComponent("Views/ExistingView.swift")
        try "Original Version 1.0".write(to: existingFile, atomically: true, encoding: .utf8)

        let dest = ProjectLocator.resolve(customRoot: tempDirectory.path)

        let modifiedFiles = [
            GeneratedFile(
                relativePath: "Generated/Views/ExistingView.swift",
                content: "Updated Version 2.0",
                status: .modified,
                framework: .swiftUI
            ),
            GeneratedFile(
                relativePath: "Generated/Views/BrandNewView.swift",
                content: "Brand New File",
                status: .created,
                framework: .swiftUI
            )
        ]

        let summary = try LocalProjectIntegrator.shared.integrate(
            files: modifiedFiles,
            destination: dest,
            createBackup: true
        )

        XCTAssertEqual(summary.modifiedFiles.count, 1)
        XCTAssertEqual(summary.addedFiles.count, 1)

        let updatedContent = try String(contentsOf: existingFile, encoding: .utf8)
        XCTAssertEqual(updatedContent, "Updated Version 2.0")

        // Now test rollback
        let success = try LocalProjectIntegrator.shared.rollback(
            backupId: summary.backupId,
            projectRoot: tempDirectory.path
        )
        XCTAssertTrue(success, "Rollback must succeed")

        let restoredContent = try String(contentsOf: existingFile, encoding: .utf8)
        XCTAssertEqual(restoredContent, "Original Version 1.0", "Original file content must be restored")

        let brandNewFile = genDir.appendingPathComponent("Views/BrandNewView.swift")
        XCTAssertFalse(FileManager.default.fileExists(atPath: brandNewFile.path), "Newly created file must be cleaned up on rollback")
    }

    func testSpokenEnglishOutputsIncludeUIKitAndStoryboardsInUIKitMode() {
        let output = SpokenEnglishArchitectureGenerator().generate(preferredFramework: .uiKit)

        let filePaths = output.files.map(\.relativePath)
        XCTAssertTrue(filePaths.contains { $0.contains("HomeDailyTargetViewController.swift") }, "Must contain UIKit HomeDailyTargetViewController")
        XCTAssertTrue(filePaths.contains { $0.contains("AICoachCorrectionViewController.swift") }, "Must contain UIKit AICoachCorrectionViewController")
        XCTAssertTrue(filePaths.contains { $0.contains("SpokenEnglishTabBarController.swift") }, "Must contain UIKit SpokenEnglishTabBarController")
        XCTAssertTrue(filePaths.contains { $0.contains("SpokenEnglish.storyboard") }, "Must contain SpokenEnglish.storyboard")
    }

    func testMockEngineClientIntegrateActuallyWritesFiles() async throws {
        let dummyProj = tempDirectory.appendingPathComponent("MockIntApp.xcodeproj")
        try? "dummy".write(to: dummyProj, atomically: true, encoding: .utf8)
        let srcDir = tempDirectory.appendingPathComponent("MockIntApp")
        try? FileManager.default.createDirectory(at: srcDir, withIntermediateDirectories: true)

        FigmaAppConfiguration.projectRootPath = tempDirectory.path
        defer { FigmaAppConfiguration.projectRootPath = nil }

        let client = MockEngineClient()
        let request = IntegrationRequest(
            resultId: UUID(),
            selectedFiles: ["Views/Generated/UIKit/HomeDailyTargetViewController.swift"],
            createBackup: true,
            targetDirectory: "Generated"
        )

        let summary = try await client.integrate(request: request)
        XCTAssertFalse(summary.addedFiles.isEmpty, "MockEngineClient must write files and report them as added")
        XCTAssertTrue(summary.targetDirectory.contains("MockIntApp"), "Target directory must point to project Generated directory")
    }
}
