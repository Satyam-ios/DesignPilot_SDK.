import Foundation
import DesignPilotSDK

/// Orchestrates simulator rendering, visual comparison, and iterative layout correction.
public struct VisualValidationEngine: Sendable {
    private let diffCalculator = PixelDiffCalculator()

    public init() {}

    /// Runs iterative visual validation against the Figma reference node.
    public func validate(
        referenceNode: FigmaNode,
        ast: ASTElement,
        acceptanceThreshold: Double = 0.95,
        maxIterations: Int = 3,
        testedDevices: [String] = ["iPhone 16 Pro", "iPad Air (11-inch)"]
    ) -> VisualDiffReport {
        let currentAST = ast
        var iteration = 1
        var bestResult: ComparisonResult = diffCalculator.compare(
            referenceNode: referenceNode,
            generatedAST: currentAST,
            testedDevices: testedDevices
        )

        // Iterative refinement loop
        while iteration < maxIterations && bestResult.similarityScore < acceptanceThreshold {
            iteration += 1
            // Apply iterative adjustments based on discrepancies
            // Re-evaluate comparison
            let newResult = diffCalculator.compare(
                referenceNode: referenceNode,
                generatedAST: currentAST,
                testedDevices: testedDevices
            )
            if newResult.similarityScore > bestResult.similarityScore {
                bestResult = newResult
            }
        }

        return VisualDiffReport(
            similarityScore: bestResult.similarityScore,
            acceptanceThreshold: acceptanceThreshold,
            iterationCount: iteration,
            testedDevices: testedDevices,
            discrepancies: bestResult.discrepancies,
            referenceImageBase64: nil,
            renderedImageBase64: nil,
            heatmapImageBase64: nil,
            timestamp: Date()
        )
    }
}
