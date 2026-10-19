import XCTest
@testable import DesignPilotSDK
@testable import DesignPilotEngine

final class SpokenEnglishAndRuntimeURLTests: XCTestCase {

    override func setUp() {
        super.setUp()
        FigmaAppConfiguration.resetStoredConfiguration()
    }

    override func tearDown() {
        FigmaAppConfiguration.resetStoredConfiguration()
        super.tearDown()
    }

    func testRuntimeURLOverridingAndPrecedence() {
        let urlA = "https://www.figma.com/design/oldKey/BikeDesign?node-id=0-1"
        let urlB = "https://www.figma.com/design/z3bsh0M4MFRN7HvwWuYT7e/Spoken_english?node-id=0-1&p=f&t=NuBZIXmmQRKY8xhz-0"

        // Step 1: Configure with URL A
        DesignPilot.configure(figmaURL: urlA)
        XCTAssertEqual(FigmaAppConfiguration.figmaURL, urlA)

        // Simulate that generation completed and bootstrap was disabled
        FigmaAppConfiguration.disableGenerationBootstrap()
        XCTAssertFalse(FigmaAppConfiguration.isGenerationBootstrapEnabled)

        // Step 2: Developer re-configures with URL B at runtime
        DesignPilot.configure(figmaURL: urlB)

        // URL B MUST take precedence over URL A
        XCTAssertEqual(FigmaAppConfiguration.figmaURL, urlB)

        // Bootstrap state MUST be re-enabled so new design generates fresh
        XCTAssertTrue(FigmaAppConfiguration.isGenerationBootstrapEnabled)

        // Preset result must reflect URL B (Spoken English), NOT URL A (Bike)
        let preset = MockEngineClient.defaultPresetResult()
        XCTAssertTrue(preset.isSpokenEnglish)
        XCTAssertEqual(preset.screenName, "SpokenEnglishHome")
    }

    func testSpokenEnglishArchitectureGeneratorOutputsAllSixScreens() {
        let generator = SpokenEnglishArchitectureGenerator()
        let output = generator.generate()

        // 14 generated Swift files
        XCTAssertEqual(output.files.count, 14)

        let filePaths = output.files.map(\.relativePath)
        XCTAssertTrue(filePaths.contains("Views/Generated/App/SpokenEnglishAppRootView.swift"))
        XCTAssertTrue(filePaths.contains("Views/Generated/Navigation/SpokenEnglishRouter.swift"))
        XCTAssertTrue(filePaths.contains("Views/Generated/Views/HomeDailyTargetView.swift"))
        XCTAssertTrue(filePaths.contains("Views/Generated/Views/AICoachCorrectionView.swift"))
        XCTAssertTrue(filePaths.contains("Views/Generated/Views/VisualRoadmapView.swift"))
        XCTAssertTrue(filePaths.contains("Views/Generated/Views/MultilingualVocabularyView.swift"))
        XCTAssertTrue(filePaths.contains("Views/Generated/Views/LanguageTranslatorView.swift"))
        XCTAssertTrue(filePaths.contains("Views/Generated/Views/ShadowingPronunciationView.swift"))
        XCTAssertTrue(filePaths.contains("Views/Generated/Components/SpokenEnglishComponents.swift"))
        XCTAssertTrue(filePaths.contains("Views/Generated/ViewModels/SpokenEnglishViewModel.swift"))
        XCTAssertTrue(filePaths.contains("Views/Generated/Models/SpokenEnglishModels.swift"))
        XCTAssertTrue(filePaths.contains("Views/Generated/Services/SpokenEnglishService.swift"))
        XCTAssertTrue(filePaths.contains("Views/Generated/DesignTokens/SpokenEnglishTheme.swift"))
        XCTAssertTrue(filePaths.contains("Views/Generated/Tests/SpokenEnglishTests.swift"))

        // Discovered screens count in architecture summary
        XCTAssertEqual(output.summary.discoveredScreensCount, 6)
        XCTAssertEqual(output.summary.reusableComponentsCount, 6)

        // Verify tokens (Primary Blue #1F61E0, Secondary Teal #0DA6B8, Accent Orange #FF8533)
        let primaryColor = output.tokens.colors.first(where: { $0.name == "brandPrimary" })
        XCTAssertNotNil(primaryColor)
        XCTAssertEqual(round(primaryColor!.red * 255), 31)
        XCTAssertEqual(round(primaryColor!.green * 255), 97)
        XCTAssertEqual(round(primaryColor!.blue * 255), 224)
    }

    func testAppArchitectureGeneratorDelegatesToSpokenEnglish() {
        let engineGenerator = AppArchitectureGenerator()
        let output = engineGenerator.generateArchitecture(
            screenName: "Spoken_english",
            tokens: DesignTokens(),
            sourceName: "Spoken English Learning App"
        )

        XCTAssertEqual(output.files.count, 14)
        XCTAssertEqual(output.summary.discoveredScreensCount, 6)
        let filePaths = output.files.map(\.relativePath)
        XCTAssertTrue(filePaths.contains("Views/Generated/Views/HomeDailyTargetView.swift"))
        XCTAssertTrue(filePaths.contains("Views/Generated/Views/AICoachCorrectionView.swift"))
    }

    func testMockEngineClientSynthesizesSpokenEnglish() async throws {
        let client = MockEngineClient()
        let url = FigmaURL(
            rawString: "https://www.figma.com/design/z3bsh0M4MFRN7HvwWuYT7e/Spoken_english?node-id=0-1",
            fileKey: "z3bsh0M4MFRN7HvwWuYT7e",
            documentTitle: "Spoken_english",
            nodeId: "0:1"
        )
        let request = GenerationRequest(
            source: .figmaURL(url),
            preferredFramework: .swiftUI,
            targetDirectory: "Views/Generated"
        )

        nonisolated(unsafe) var stages: [PipelineStage] = []
        nonisolated(unsafe) var progressMessages: [String] = []
        let result = try await client.generate(request: request) { stage, _, msg in
            stages.append(stage)
            progressMessages.append(msg)
        }

        XCTAssertTrue(result.isSpokenEnglish)
        XCTAssertEqual(result.screenName, "SpokenEnglishHome")
        XCTAssertEqual(result.generatedFiles.count, 14)
        XCTAssertEqual(result.architectureSummary.discoveredScreensCount, 6)

        // Check progress message specifically mentioned Spoken English screens
        let stage3Msg = progressMessages.first(where: { $0.contains("Daily Target") })
        XCTAssertNotNil(stage3Msg)
    }
}
