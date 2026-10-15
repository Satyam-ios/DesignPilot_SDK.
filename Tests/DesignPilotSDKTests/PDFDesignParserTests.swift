import XCTest
import PDFKit
import CoreGraphics
@testable import DesignPilotSDK
@testable import DesignPilotEngine

final class PDFDesignParserTests: XCTestCase {

    private func createTestPDFData() -> Data {
        let pdfData = NSMutableData()
        guard let consumer = CGDataConsumer(data: pdfData as CFMutableData) else { return Data() }
        var mediaBox = CGRect(x: 0, y: 0, width: 375, height: 812)
        guard let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else { return Data() }

        context.beginPDFPage(nil)
        context.endPDFPage()
        context.closePDF()
        return pdfData as Data
    }

    func testParseValidPDFData() throws {
        let pdfData = createTestPDFData()
        XCTAssertFalse(pdfData.isEmpty)

        let source = PDFSourceInfo(
            filePath: "",
            fileName: "Context to Call - IoT Device (Figma Flow) V1.3.pdf",
            pageCount: 1,
            selectedPage: 1,
            fileSizeInBytes: pdfData.count,
            fileData: pdfData
        )

        let parser = PDFDesignParser()
        let result = try parser.parse(source: source)

        XCTAssertEqual(result.pageIndex, 1)
        XCTAssertEqual(result.totalPages, 1)
        XCTAssertFalse(result.screenName.isEmpty)
        XCTAssertFalse(result.tokens.colors.isEmpty)
        XCTAssertFalse(result.tokens.typography.isEmpty)
        XCTAssertNotNil(result.referenceImageData)

        // Verify AST structure
        if case .container(let type, _, let children, _) = result.ast {
            if case .scrollContainer = type {
                XCTAssertFalse(children.isEmpty)
            } else {
                XCTFail("Root AST element should be a scroll container")
            }
        } else {
            XCTFail("Root AST element should be a container")
        }
    }

    func testInvalidPDFThrowsError() {
        let invalidData = "This is not a PDF file".data(using: .utf8)!
        let source = PDFSourceInfo(
            filePath: "",
            fileName: "Corrupted.pdf",
            pageCount: 1,
            selectedPage: 1,
            fileSizeInBytes: invalidData.count,
            fileData: invalidData
        )

        let parser = PDFDesignParser()
        XCTAssertThrowsError(try parser.parse(source: source)) { error in
            guard let dpError = error as? DesignPilotError else {
                XCTFail("Expected DesignPilotError, got \(error)")
                return
            }
            if case .invalidPDF = dpError {
                // Expected
            } else {
                XCTFail("Expected .invalidPDF error, got \(dpError)")
            }
        }
    }

    func testOutOfBoundsPageThrowsError() {
        let pdfData = createTestPDFData()
        let source = PDFSourceInfo(
            filePath: "",
            fileName: "Test.pdf",
            pageCount: 1,
            selectedPage: 5, // Out of bounds for 1-page document
            fileSizeInBytes: pdfData.count,
            fileData: pdfData
        )

        let parser = PDFDesignParser()
        XCTAssertThrowsError(try parser.parse(source: source, targetPage: 10)) { error in
            guard let dpError = error as? DesignPilotError else {
                XCTFail("Expected DesignPilotError, got \(error)")
                return
            }
            if case .pdfPageNotFound(let page, let total) = dpError {
                XCTAssertEqual(page, 10)
                XCTAssertEqual(total, 1)
            } else {
                XCTFail("Expected .pdfPageNotFound, got \(dpError)")
            }
        }
    }

    func testPDFSourceInfoFormatting() {
        let info = PDFSourceInfo(
            filePath: "/path/to/flow.pdf",
            fileName: "flow.pdf",
            pageCount: 8,
            selectedPage: 3,
            fileSizeInBytes: 2_450_000
        )

        XCTAssertEqual(info.fileName, "flow.pdf")
        XCTAssertEqual(info.selectedPage, 3)
        XCTAssertEqual(info.pageCount, 8)
        XCTAssertFalse(info.formattedFileSize.isEmpty)
    }
}
