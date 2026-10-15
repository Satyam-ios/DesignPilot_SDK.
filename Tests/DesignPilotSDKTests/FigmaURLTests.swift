import XCTest
@testable import DesignPilotSDK

final class FigmaURLTests: XCTestCase {
    func testValidDesignURLParsing() throws {
        let urlString = "https://www.figma.com/design/d8QW90X7vLp/DesignPilot-iOS-Design-System?node-id=402-1200"
        let parsed = try FigmaURL.parse(urlString)

        XCTAssertEqual(parsed.fileKey, "d8QW90X7vLp")
        XCTAssertEqual(parsed.documentTitle, "DesignPilot-iOS-Design-System")
        XCTAssertEqual(parsed.nodeId, "402-1200")
        XCTAssertEqual(parsed.apiNodeId, "402:1200")
    }

    func testValidFileURLParsing() throws {
        let urlString = "https://figma.com/file/aBcDeFgHiJk/MobileAppScreen"
        let parsed = try FigmaURL.parse(urlString)

        XCTAssertEqual(parsed.fileKey, "aBcDeFgHiJk")
        XCTAssertEqual(parsed.documentTitle, "MobileAppScreen")
        XCTAssertNil(parsed.nodeId)
        XCTAssertNil(parsed.apiNodeId)
    }

    func testEmptyURLThrows() {
        XCTAssertThrowsError(try FigmaURL.parse("")) { error in
            guard let urlError = error as? FigmaURLError else {
                XCTFail("Expected FigmaURLError")
                return
            }
            XCTAssertEqual(urlError, .emptyURL)
        }
    }

    func testInvalidHostThrows() {
        XCTAssertThrowsError(try FigmaURL.parse("https://google.com/design/1234567890/test")) { error in
            guard let urlError = error as? FigmaURLError else {
                XCTFail("Expected FigmaURLError")
                return
            }
            XCTAssertEqual(urlError, .invalidHost)
        }
    }

    func testMissingKeyThrows() {
        XCTAssertThrowsError(try FigmaURL.parse("https://figma.com/design")) { error in
            guard let urlError = error as? FigmaURLError else {
                XCTFail("Expected FigmaURLError")
                return
            }
            XCTAssertEqual(urlError, .missingFileKey)
        }
    }
}
