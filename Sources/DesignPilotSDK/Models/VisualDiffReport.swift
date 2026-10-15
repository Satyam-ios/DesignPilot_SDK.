import Foundation

public enum DiscrepancyType: String, Codable, Sendable, CaseIterable {
    case spacing = "Spacing"
    case alignment = "Alignment"
    case typography = "Typography"
    case color = "Color"
    case sizing = "Sizing"
    case cornerRadius = "Corner Radius"
}

public enum DiscrepancySeverity: String, Codable, Sendable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

public struct VisualDiscrepancy: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public let type: DiscrepancyType
    public let elementName: String
    public let expected: String
    public let actual: String
    public let suggestedFix: String
    public let severity: DiscrepancySeverity

    public init(
        id: UUID = UUID(),
        type: DiscrepancyType,
        elementName: String,
        expected: String,
        actual: String,
        suggestedFix: String,
        severity: DiscrepancySeverity = .medium
    ) {
        self.id = id
        self.type = type
        self.elementName = elementName
        self.expected = expected
        self.actual = actual
        self.suggestedFix = suggestedFix
        self.severity = severity
    }
}

/// Comprehensive report comparing the Figma reference design with the simulator-rendered screen.
public struct VisualDiffReport: Codable, Sendable, Hashable {
    public let similarityScore: Double // 0.0 to 1.0 (e.g. 0.985 = 98.5%)
    public let acceptanceThreshold: Double
    public let passedThreshold: Bool
    public let iterationCount: Int
    public let testedDevices: [String]
    public let discrepancies: [VisualDiscrepancy]
    public let referenceImageBase64: String?
    public let renderedImageBase64: String?
    public let heatmapImageBase64: String?
    public let timestamp: Date

    public init(
        similarityScore: Double,
        acceptanceThreshold: Double = 0.95,
        iterationCount: Int = 1,
        testedDevices: [String] = ["iPhone 16 Pro", "iPad Air (11-inch)"],
        discrepancies: [VisualDiscrepancy] = [],
        referenceImageBase64: String? = nil,
        renderedImageBase64: String? = nil,
        heatmapImageBase64: String? = nil,
        timestamp: Date = Date()
    ) {
        self.similarityScore = similarityScore
        self.acceptanceThreshold = acceptanceThreshold
        self.passedThreshold = similarityScore >= acceptanceThreshold
        self.iterationCount = iterationCount
        self.testedDevices = testedDevices
        self.discrepancies = discrepancies
        self.referenceImageBase64 = referenceImageBase64
        self.renderedImageBase64 = renderedImageBase64
        self.heatmapImageBase64 = heatmapImageBase64
        self.timestamp = timestamp
    }

    public var similarityPercentageFormatted: String {
        String(format: "%.1f%%", similarityScore * 100.0)
    }
}
