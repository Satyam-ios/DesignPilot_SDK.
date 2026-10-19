import XCTest
@testable import DesignPilotSDK
@testable import DesignPilotEngine

final class StoryboardAndBootstrapTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Ensure clean state before each test
        UserDefaults.standard.removeObject(forKey: "DesignPilot_isGenerationBootstrapEnabled")
        FigmaAppConfiguration.isGenerationBootstrapEnabled = true
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "DesignPilot_isGenerationBootstrapEnabled")
        super.tearDown()
    }

    func testBootstrapEnableDisablePersistence() {
        // Default on first launch should be enabled
        XCTAssertTrue(FigmaAppConfiguration.isGenerationBootstrapEnabled)

        // Disable generation bootstrap
        FigmaAppConfiguration.disableGenerationBootstrap()
        XCTAssertFalse(FigmaAppConfiguration.isGenerationBootstrapEnabled)

        // Verify stored in UserDefaults
        let stored = UserDefaults.standard.bool(forKey: "DesignPilot_isGenerationBootstrapEnabled")
        XCTAssertFalse(stored)

        // Re-enable generation bootstrap
        FigmaAppConfiguration.enableGenerationBootstrap()
        XCTAssertTrue(FigmaAppConfiguration.isGenerationBootstrapEnabled)
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "DesignPilot_isGenerationBootstrapEnabled"))
    }

    func testConfigureWithBootstrapParameter() {
        DesignPilot.configure(
            figmaURL: "https://www.figma.com/design/z3bsh0M4MFRN7HvwWuYT7e/Untitled?node-id=0-1",
            uiFramework: .swiftUI,
            autoGenerateOnLaunch: true,
            isGenerationBootstrapEnabled: false
        )

        XCTAssertFalse(FigmaAppConfiguration.isGenerationBootstrapEnabled)
    }

    func testStoryboardLayoutGeneratorGeneratesValidXML() {
        let generator = StoryboardLayoutGenerator()
        let xml = generator.generateMainStoryboard()

        // Verify XML header and InterfaceBuilder tags
        XCTAssertTrue(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        XCTAssertTrue(xml.contains("<document type=\"com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB\""))
        XCTAssertTrue(xml.contains("</document>"))

        // Verify View Controllers
        XCTAssertTrue(xml.contains("customClass=\"OnlineBikeCatalogViewController\""))
        XCTAssertTrue(xml.contains("customClass=\"ShoppingCartViewController\""))
        XCTAssertTrue(xml.contains("customClass=\"OnlineBikeTabBarController\""))

        // Verify Outlets and Actions
        XCTAssertTrue(xml.contains("<outlet property=\"headerTitleLabel\""))
        XCTAssertTrue(xml.contains("<outlet property=\"searchButton\""))
        XCTAssertTrue(xml.contains("<outlet property=\"heroDiscountCardView\""))
        XCTAssertTrue(xml.contains("<outlet property=\"bikesCollectionView\""))
        XCTAssertTrue(xml.contains("<action selector=\"searchButtonTapped:\""))

        XCTAssertTrue(xml.contains("<outlet property=\"cartTitleLabel\""))
        XCTAssertTrue(xml.contains("<outlet property=\"cartTableView\""))
        XCTAssertTrue(xml.contains("<outlet property=\"totalSummaryCardView\""))
        XCTAssertTrue(xml.contains("<outlet property=\"totalAmountLabel\""))
        XCTAssertTrue(xml.contains("<outlet property=\"checkoutButton\""))
        XCTAssertTrue(xml.contains("<action selector=\"checkoutButtonTapped:\""))
    }

    func testStoryboardValidatorVerifiesCleanConnections() {
        let generator = StoryboardLayoutGenerator()
        let xml = generator.generateMainStoryboard()
        let catalogCode = generator.generateCatalogViewControllerCode()
        let cartCode = generator.generateShoppingCartViewControllerCode()

        let validator = StoryboardValidator()
        let report = validator.validate(
            storyboardXML: xml,
            viewControllerSources: [catalogCode, cartCode]
        )

        XCTAssertTrue(report.isValid, "Storyboard connections should be 100% valid. Failures: \(report.brokenConnections)")
        XCTAssertEqual(report.brokenConnections.count, 0)
        XCTAssertGreaterThanOrEqual(report.verifiedOutletsCount, 9)
        XCTAssertGreaterThanOrEqual(report.verifiedActionsCount, 2)
        XCTAssertTrue(report.verifiedOutlets.contains("headerTitleLabel"))
        XCTAssertTrue(report.verifiedOutlets.contains("cartTitleLabel"))
        XCTAssertTrue(report.verifiedActions.contains("searchButtonTapped"))
        XCTAssertTrue(report.verifiedActions.contains("checkoutButtonTapped"))
    }

    func testStoryboardValidatorCatchesMissingOutlet() {
        let generator = StoryboardLayoutGenerator()
        let xml = generator.generateMainStoryboard()

        // Swift code with an outlet not present in the Storyboard
        let brokenCode = """
        import UIKit

        public class BrokenViewController: UIViewController {
            @IBOutlet public weak var missingMysteryLabel: UILabel!
        }
        """

        let validator = StoryboardValidator()
        let report = validator.validate(
            storyboardXML: xml,
            viewControllerSources: [brokenCode]
        )

        XCTAssertFalse(report.isValid)
        XCTAssertTrue(report.brokenConnections.contains(where: { $0.contains("missingMysteryLabel") }))
    }
}
