import Foundation
import DesignPilotSDK

/// Extracts reusable design tokens from Figma nodes, styles, and components.
public struct FigmaTokenExtractor: Sendable {
    public init() {}

    /// Extracts unified design tokens from a Figma node hierarchy.
    public func extract(from rootNode: FigmaNode) -> DesignTokens {
        var colors: [String: ColorToken] = [:]
        var typography: [String: TypographyToken] = [:]
        var spacingSet: Set<Double> = []
        var radiiSet: Set<Double> = []
        var shadows: [String: ShadowToken] = [:]

        traverse(node: rootNode) { node in
            // Extract colors from fills
            if let fills = node.fills {
                for (index, fill) in fills.enumerated() where fill.type == "SOLID" && (fill.visible ?? true) {
                    if let color = fill.color {
                        let alpha = (color.a) * (fill.opacity ?? 1.0) * (node.opacity ?? 1.0)
                        let tokenName = sanitizeIdentifier("\(node.name.lowercased())Color_\(index)")
                        let token = ColorToken(name: tokenName, red: color.r, green: color.g, blue: color.b, alpha: alpha)
                        if colors[token.hex] == nil {
                            colors[token.hex] = token
                        }
                    }
                }
            }

            // Extract typography
            if node.nodeType == .text, let style = node.style, let fontSize = style.fontSize {
                let family = style.fontFamily ?? "SF Pro"
                let weightName = weightNameFrom(style.fontWeight)
                let tokenName = sanitizeIdentifier("\(node.name.lowercased())Style")
                let typo = TypographyToken(
                    name: tokenName,
                    fontFamily: family,
                    fontSize: fontSize,
                    fontWeight: weightName,
                    lineHeight: style.lineHeightPx,
                    letterSpacing: style.letterSpacing
                )
                typography[tokenName] = typo
            }

            // Extract spacing
            if let spacing = node.itemSpacing, spacing > 0 {
                spacingSet.insert(spacing)
            }

            // Extract corner radii
            if let radius = node.cornerRadius, radius > 0 {
                radiiSet.insert(radius)
            }

            // Extract shadows
            if let effects = node.effects {
                for (index, effect) in effects.enumerated() where effect.type == "DROP_SHADOW" && (effect.visible ?? true) {
                    let hex = effect.color != nil ? hexFrom(r: effect.color!.r, g: effect.color!.g, b: effect.color!.b) : "#000000"
                    let alpha = effect.color?.a ?? 0.15
                    let shadowName = sanitizeIdentifier("\(node.name.lowercased())Shadow_\(index)")
                    let shadow = ShadowToken(
                        name: shadowName,
                        colorHex: hex,
                        colorAlpha: alpha,
                        radius: effect.radius,
                        x: effect.offset?.x ?? 0,
                        y: effect.offset?.y ?? 0
                    )
                    shadows[shadowName] = shadow
                }
            }
        }

        // Map spacing and radii to named tokens
        let sortedSpacing = spacingSet.sorted().enumerated().map { index, val in
            SpacingToken(name: spacingName(for: index, value: val), value: val)
        }
        let sortedRadii = radiiSet.sorted().enumerated().map { index, val in
            CornerRadiusToken(name: radiusName(for: index, value: val), value: val)
        }

        return DesignTokens(
            colors: Array(colors.values),
            typography: Array(typography.values),
            spacing: sortedSpacing,
            radii: sortedRadii,
            shadows: Array(shadows.values)
        )
    }

    private func traverse(node: FigmaNode, visitor: (FigmaNode) -> Void) {
        visitor(node)
        if let children = node.children {
            for child in children {
                traverse(node: child, visitor: visitor)
            }
        }
    }

    private func sanitizeIdentifier(_ str: String) -> String {
        let cleaned = str.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        return cleaned.isEmpty ? "token" : cleaned
    }

    private func weightNameFrom(_ weight: Double?) -> String {
        guard let w = weight else { return "Regular" }
        switch Int(w) {
        case ..<300: return "Light"
        case 300..<450: return "Regular"
        case 450..<600: return "Medium"
        case 600..<750: return "Semibold"
        case 750...: return "Bold"
        default: return "Regular"
        }
    }

    private func spacingName(for index: Int, value: Double) -> String {
        if value <= 4 { return "xs" }
        if value <= 8 { return "sm" }
        if value <= 16 { return "md" }
        if value <= 24 { return "lg" }
        return "spacing_\(Int(value))"
    }

    private func radiusName(for index: Int, value: Double) -> String {
        if value <= 8 { return "small" }
        if value <= 16 { return "card" }
        if value <= 24 { return "container" }
        return "radius_\(Int(value))"
    }

    private func hexFrom(r: Double, g: Double, b: Double) -> String {
        let ri = Int(round(r * 255))
        let gi = Int(round(g * 255))
        let bi = Int(round(b * 255))
        return String(format: "#%02X%02X%02X", ri, gi, bi)
    }
}
