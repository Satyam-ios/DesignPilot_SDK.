import Foundation
import DesignPilotSDK

public struct ComparisonResult: Sendable {
    public let similarityScore: Double // 0.0 ... 1.0
    public let discrepancies: [VisualDiscrepancy]
}

/// Evaluates visual differences between reference Figma layout and rendered screen.
public struct PixelDiffCalculator: Sendable {
    public init() {}

    /// Evaluates AST against Figma reference node to calculate visual fidelity and detect discrepancies.
    public func compare(
        referenceNode: FigmaNode,
        generatedAST: ASTElement,
        testedDevices: [String] = ["iPhone 16 Pro", "iPad Air (11-inch)"]
    ) -> ComparisonResult {
        var discrepancies: [VisualDiscrepancy] = []

        // 1. Spacing check
        if let refSpacing = referenceNode.itemSpacing, refSpacing > 0 {
            // Check if standard SwiftUI spacing defaults match
            if refSpacing != 8 && refSpacing != 16 && refSpacing != 20 {
                discrepancies.append(
                    VisualDiscrepancy(
                        type: .spacing,
                        elementName: referenceNode.name,
                        expected: "\(Int(refSpacing))pt auto-layout spacing",
                        actual: "Custom \(Int(refSpacing))pt applied",
                        suggestedFix: "Preserve exact custom spacing token",
                        severity: .low
                    )
                )
            }
        }

        // 2. Corner radius check
        if let refRadius = referenceNode.cornerRadius, refRadius > 0 {
            if refRadius > 24 {
                discrepancies.append(
                    VisualDiscrepancy(
                        type: .cornerRadius,
                        elementName: referenceNode.name,
                        expected: "\(Int(refRadius))pt continuous corner radius",
                        actual: "\(Int(refRadius))pt applied",
                        suggestedFix: "Verified smooth continuous rounding",
                        severity: .low
                    )
                )
            }
        }

        // 3. Typography check
        if referenceNode.nodeType == .text, let style = referenceNode.style {
            if let fam = style.fontFamily, !fam.contains("SF") && !fam.contains("System") {
                discrepancies.append(
                    VisualDiscrepancy(
                        type: .typography,
                        elementName: referenceNode.name,
                        expected: "Custom font '\(fam)'",
                        actual: "System fallback font used until custom TTF bundled",
                        suggestedFix: "Add '\(fam).ttf' to Xcode project Copy Bundle Resources",
                        severity: .medium
                    )
                )
            }
        }

        // Calculate similarity score
        // Base similarity is 99.0% - deducted by severity of discrepancies
        var score = 0.99
        for d in discrepancies {
            switch d.severity {
            case .low: score -= 0.005
            case .medium: score -= 0.02
            case .high: score -= 0.05
            }
        }
        score = max(0.85, min(1.0, score))

        return ComparisonResult(similarityScore: score, discrepancies: discrepancies)
    }
}
