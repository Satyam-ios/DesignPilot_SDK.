import XCTest
@testable import DesignPilotSDK
@testable import DesignPilotEngine

final class AutoLayoutTranspilerTests: XCTestCase {
    func testTokenExtractionFromNode() {
        let node = FigmaNode(
            id: "1:1",
            name: "Card",
            type: "FRAME",
            itemSpacing: 16,
            cornerRadius: 12,
            fills: [FigmaPaint(type: "SOLID", color: FigmaColor(r: 0.1, g: 0.5, b: 0.9))],
            effects: [FigmaEffect(type: "DROP_SHADOW", radius: 8, offset: FigmaOffset(x: 0, y: 4))]
        )

        let extractor = FigmaTokenExtractor()
        let tokens = extractor.extract(from: node)

        XCTAssertFalse(tokens.colors.isEmpty)
        XCTAssertEqual(tokens.colors.first?.hex, "#1A80E6")
        XCTAssertEqual(tokens.spacing.first?.value, 16)
        XCTAssertEqual(tokens.radii.first?.value, 12)
        XCTAssertEqual(tokens.shadows.first?.radius, 8)
    }

    func testSwiftUILayoutGenerator() {
        let node = FigmaNode(
            id: "1:1",
            name: "LoginScreen",
            type: "FRAME",
            children: [
                FigmaNode(
                    id: "1:2",
                    name: "Title",
                    type: "TEXT",
                    characters: "Welcome",
                    style: FigmaTypeStyle(fontWeight: 700, fontSize: 24)
                ),
                FigmaNode(
                    id: "1:3",
                    name: "SubmitButton",
                    type: "FRAME",
                    children: [
                        FigmaNode(id: "1:4", name: "Label", type: "TEXT", characters: "Log In")
                    ]
                )
            ],
            layoutMode: "VERTICAL",
            itemSpacing: 20,
            paddingLeft: 16,
            paddingRight: 16,
            paddingTop: 16,
            paddingBottom: 16
        )

        let parser = AutoLayoutParser()
        let ast = parser.parse(rootNode: node)
        let generator = SwiftUILayoutGenerator()
        let swiftCode = generator.generate(ast: ast, screenName: "LoginScreen")

        XCTAssertTrue(swiftCode.contains("public struct LoginScreenView: View"))
        XCTAssertTrue(swiftCode.contains("VStack(alignment: .leading, spacing: 20)"))
        XCTAssertTrue(swiftCode.contains("Text(\"Welcome\")"))
        XCTAssertTrue(swiftCode.contains("Button(action:"))
        XCTAssertTrue(swiftCode.contains("#Preview"))
    }

    func testUIKitLayoutGenerator() {
        let parser = AutoLayoutParser()
        let node = FigmaNode(id: "1:1", name: "ProfileScreen", type: "FRAME", layoutMode: "VERTICAL")
        let ast = parser.parse(rootNode: node)
        let generator = UIKitLayoutGenerator()
        let uikitCode = generator.generate(ast: ast, screenName: "ProfileScreen")

        XCTAssertTrue(uikitCode.contains("ProfileScreenViewController: UIViewController"))
        XCTAssertTrue(uikitCode.contains("UIStackView()"))
        XCTAssertTrue(uikitCode.contains("NSLayoutConstraint.activate"))
    }
}
