import XCTest
@testable import DesignPilotSDK
@testable import DesignPilotEngine

final class VisualValidationTests: XCTestCase {
    func testVisualDiffThresholdPassing() {
        let referenceNode = FigmaNode(
            id: "1:1",
            name: "Header",
            type: "FRAME",
            itemSpacing: 16,
            cornerRadius: 12
        )

        let parser = AutoLayoutParser()
        let ast = parser.parse(rootNode: referenceNode)

        let validator = VisualValidationEngine()
        let report = validator.validate(referenceNode: referenceNode, ast: ast, acceptanceThreshold: 0.95)

        XCTAssertTrue(report.similarityScore >= 0.95)
        XCTAssertTrue(report.passedThreshold)
        XCTAssertFalse(report.testedDevices.isEmpty)
    }

    func testDiscrepancySeverityCalculation() {
        let referenceNode = FigmaNode(
            id: "1:1",
            name: "CustomLabel",
            type: "TEXT",
            characters: "Hello World",
            style: FigmaTypeStyle(fontFamily: "CustomRareFont", fontSize: 18)
        )

        let parser = AutoLayoutParser()
        let ast = parser.parse(rootNode: referenceNode)
        let calc = PixelDiffCalculator()
        let result = calc.compare(referenceNode: referenceNode, generatedAST: ast)

        XCTAssertTrue(result.discrepancies.contains(where: { $0.type == .typography }))
        XCTAssertTrue(result.similarityScore < 1.0)
    }
}
