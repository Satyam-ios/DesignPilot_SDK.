import Foundation

/// Request payload describing a generation task for Figma URLs or PDF files.
public struct GenerationRequest: Codable, Sendable {
    public let source: DesignSource
    public let preferredFramework: TargetFramework
    public let targetDirectory: String
    public let visualAcceptanceThreshold: Double
    public let maxVisualIterations: Int
    public let extractDesignTokens: Bool
    public let generatePreviews: Bool

    public var figmaURL: FigmaURL? {
        source.figmaURL
    }

    public var pdfInfo: PDFSourceInfo? {
        source.pdfInfo
    }

    public init(
        source: DesignSource,
        preferredFramework: TargetFramework = .swiftUI,
        targetDirectory: String = "Views/Generated",
        visualAcceptanceThreshold: Double = 0.95,
        maxVisualIterations: Int = 3,
        extractDesignTokens: Bool = true,
        generatePreviews: Bool = true
    ) {
        self.source = source
        self.preferredFramework = preferredFramework
        self.targetDirectory = targetDirectory
        self.visualAcceptanceThreshold = visualAcceptanceThreshold
        self.maxVisualIterations = maxVisualIterations
        self.extractDesignTokens = extractDesignTokens
        self.generatePreviews = generatePreviews
    }

    /// Convenience initializer maintaining backwards-compatibility for direct Figma URLs.
    public init(
        figmaURL: FigmaURL,
        preferredFramework: TargetFramework = .swiftUI,
        targetDirectory: String = "Views/Generated",
        visualAcceptanceThreshold: Double = 0.95,
        maxVisualIterations: Int = 3,
        extractDesignTokens: Bool = true,
        generatePreviews: Bool = true
    ) {
        self.init(
            source: .figmaURL(figmaURL),
            preferredFramework: preferredFramework,
            targetDirectory: targetDirectory,
            visualAcceptanceThreshold: visualAcceptanceThreshold,
            maxVisualIterations: maxVisualIterations,
            extractDesignTokens: extractDesignTokens,
            generatePreviews: generatePreviews
        )
    }
}

/// Request to commit staged files to the Xcode project.
public struct IntegrationRequest: Codable, Sendable {
    public let resultId: UUID
    public let selectedFiles: [String]
    public let createBackup: Bool
    public let targetDirectory: String
    public let generatedFiles: [GeneratedFile]?
    public let projectRootPath: String?

    public init(
        resultId: UUID,
        selectedFiles: [String],
        createBackup: Bool = true,
        targetDirectory: String = "Views/Generated",
        generatedFiles: [GeneratedFile]? = nil,
        projectRootPath: String? = nil
    ) {
        self.resultId = resultId
        self.selectedFiles = selectedFiles
        self.createBackup = createBackup
        self.targetDirectory = targetDirectory
        self.generatedFiles = generatedFiles
        self.projectRootPath = projectRootPath
    }
}
