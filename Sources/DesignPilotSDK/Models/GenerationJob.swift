import Foundation

/// Request payload describing a generation task.
public struct GenerationRequest: Codable, Sendable {
    public let figmaURL: FigmaURL
    public let preferredFramework: TargetFramework
    public let targetDirectory: String
    public let visualAcceptanceThreshold: Double
    public let maxVisualIterations: Int
    public let extractDesignTokens: Bool
    public let generatePreviews: Bool

    public init(
        figmaURL: FigmaURL,
        preferredFramework: TargetFramework = .swiftUI,
        targetDirectory: String = "Views/Generated",
        visualAcceptanceThreshold: Double = 0.95,
        maxVisualIterations: Int = 3,
        extractDesignTokens: Bool = true,
        generatePreviews: Bool = true
    ) {
        self.figmaURL = figmaURL
        self.preferredFramework = preferredFramework
        self.targetDirectory = targetDirectory
        self.visualAcceptanceThreshold = visualAcceptanceThreshold
        self.maxVisualIterations = maxVisualIterations
        self.extractDesignTokens = extractDesignTokens
        self.generatePreviews = generatePreviews
    }
}

/// Request to commit staged files to the Xcode project.
public struct IntegrationRequest: Codable, Sendable {
    public let resultId: UUID
    public let selectedFiles: [String]
    public let createBackup: Bool
    public let targetDirectory: String

    public init(
        resultId: UUID,
        selectedFiles: [String],
        createBackup: Bool = true,
        targetDirectory: String = "Views/Generated"
    ) {
        self.resultId = resultId
        self.selectedFiles = selectedFiles
        self.createBackup = createBackup
        self.targetDirectory = targetDirectory
    }
}
