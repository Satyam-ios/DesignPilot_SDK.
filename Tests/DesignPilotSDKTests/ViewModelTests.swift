import XCTest
@testable import DesignPilotSDK

@MainActor
final class ViewModelTests: XCTestCase {
    func testSaveURLDistinguishedFromGenerate() {
        let mockClient = MockEngineClient()
        let vm = DesignPilotViewModel(client: mockClient)

        vm.urlInput = "https://www.figma.com/design/d8QW90X7vLp/DashboardScreen?node-id=10-20"
        vm.saveURL()

        // Verify URL is saved but generation is NOT started
        XCTAssertNotNil(vm.savedURL)
        XCTAssertEqual(vm.savedURL?.fileKey, "d8QW90X7vLp")
        if case .saved(let url) = vm.state {
            XCTAssertEqual(url.fileKey, "d8QW90X7vLp")
        } else {
            XCTFail("Expected state to be .saved, got \(vm.state)")
        }
        XCTAssertNil(vm.lastResult)
    }

    func testInvalidURLHandling() {
        let mockClient = MockEngineClient()
        let vm = DesignPilotViewModel(client: mockClient)

        vm.urlInput = "https://notfigma.com/file/123"
        vm.saveURL()

        XCTAssertNotNil(vm.validationError)
        XCTAssertNil(vm.savedURL)
    }

    func testFullGenerationWorkflow() async throws {
        let mockClient = MockEngineClient()
        let vm = DesignPilotViewModel(client: mockClient)

        vm.urlInput = "https://www.figma.com/design/d8QW90X7vLp/DashboardScreen?node-id=10-20"
        vm.generateUI()

        // Wait for pipeline execution
        try await Task.sleep(nanoseconds: 3_000_000_000)

        XCTAssertNotNil(vm.lastResult)
        XCTAssertEqual(vm.currentStage, .readyForReview)
        XCTAssertFalse(vm.lastResult!.generatedFiles.isEmpty)
        XCTAssertTrue(vm.lastResult!.visualDiff.passedThreshold)

        // Test Integration step
        let files = vm.lastResult!.generatedFiles.map(\.relativePath)
        vm.integrateFiles(selectedFiles: files)

        try await Task.sleep(nanoseconds: 1_000_000_000)

        XCTAssertNotNil(vm.lastIntegrationSummary)
        XCTAssertEqual(vm.currentStage, .completed)
    }
}
