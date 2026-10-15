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
        if case .savedSource(let source) = vm.state {
            XCTAssertEqual(source.figmaURL?.fileKey, "d8QW90X7vLp")
        } else {
            XCTFail("Expected state to be .savedSource, got \(vm.state)")
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

    func testSavePDFSourceDistinguishedFromGenerate() {
        let mockClient = MockEngineClient()
        let vm = DesignPilotViewModel(client: mockClient)

        vm.inputMode = .pdfUpload
        let info = PDFSourceInfo(
            filePath: "/test/IoT_Flow.pdf",
            fileName: "IoT_Flow.pdf",
            pageCount: 4,
            selectedPage: 2,
            fileSizeInBytes: 1024
        )
        vm.selectedPDFInfo = info
        vm.savePDFSource()

        XCTAssertNotNil(vm.savedPDF)
        XCTAssertEqual(vm.savedPDF?.fileName, "IoT_Flow.pdf")
        XCTAssertEqual(vm.savedPDF?.selectedPage, 2)
        if case .savedSource(let source) = vm.state {
            XCTAssertTrue(source.isPDF)
            XCTAssertEqual(source.displayName, "IoT_Flow.pdf")
        } else {
            XCTFail("Expected state to be .savedSource, got \(vm.state)")
        }
        XCTAssertNil(vm.lastResult)
    }

    func testPDFGenerationWorkflow() async throws {
        let mockClient = MockEngineClient()
        let vm = DesignPilotViewModel(client: mockClient)

        vm.inputMode = .pdfUpload
        let info = PDFSourceInfo(
            filePath: "/test/Context_to_Call_IoT_Device.pdf",
            fileName: "Context_to_Call_IoT_Device.pdf",
            pageCount: 3,
            selectedPage: 1,
            fileSizeInBytes: 2048
        )
        vm.selectedPDFInfo = info
        vm.generateUIFromPDF()

        // Wait for pipeline execution
        try await Task.sleep(nanoseconds: 3_000_000_000)

        XCTAssertNotNil(vm.lastResult)
        XCTAssertEqual(vm.currentStage, .readyForReview)
        XCTAssertTrue(vm.lastResult!.source.isPDF)
        XCTAssertFalse(vm.lastResult!.screenName.isEmpty)
        XCTAssertFalse(vm.lastResult!.generatedFiles.isEmpty)
        XCTAssertTrue(vm.lastResult!.visualDiff.passedThreshold)
    }
}

