import Foundation

/// Unified design tokens extracted from Figma styles and components.
public struct DesignTokens: Codable, Sendable, Hashable {
    public var colors: [ColorToken]
    public var typography: [TypographyToken]
    public var spacing: [SpacingToken]
    public var radii: [CornerRadiusToken]
    public var shadows: [ShadowToken]

    public init(
        colors: [ColorToken] = [],
        typography: [TypographyToken] = [],
        spacing: [SpacingToken] = [],
        radii: [CornerRadiusToken] = [],
        shadows: [ShadowToken] = []
    ) {
        self.colors = colors
        self.typography = typography
        self.spacing = spacing
        self.radii = radii
        self.shadows = shadows
    }
}

public struct ColorToken: Codable, Sendable, Hashable, Identifiable {
    public var id: String { name }
    public let name: String
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double
    public let hex: String

    public init(name: String, red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.name = name
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
        let r = Int(round(red * 255))
        let g = Int(round(green * 255))
        let b = Int(round(blue * 255))
        self.hex = String(format: "#%02X%02X%02X", r, g, b)
    }
}

public struct TypographyToken: Codable, Sendable, Hashable, Identifiable {
    public var id: String { name }
    public let name: String
    public let fontFamily: String
    public let fontSize: Double
    public let fontWeight: String
    public let lineHeight: Double?
    public let letterSpacing: Double?

    public init(name: String, fontFamily: String, fontSize: Double, fontWeight: String, lineHeight: Double? = nil, letterSpacing: Double? = nil) {
        self.name = name
        self.fontFamily = fontFamily
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
    }
}

public struct SpacingToken: Codable, Sendable, Hashable, Identifiable {
    public var id: String { name }
    public let name: String
    public let value: Double

    public init(name: String, value: Double) {
        self.name = name
        self.value = value
    }
}

public struct CornerRadiusToken: Codable, Sendable, Hashable, Identifiable {
    public var id: String { name }
    public let name: String
    public let value: Double

    public init(name: String, value: Double) {
        self.name = name
        self.value = value
    }
}

public struct ShadowToken: Codable, Sendable, Hashable, Identifiable {
    public var id: String { name }
    public let name: String
    public let colorHex: String
    public let colorAlpha: Double
    public let radius: Double
    public let x: Double
    public let y: Double

    public init(name: String, colorHex: String, colorAlpha: Double, radius: Double, x: Double, y: Double) {
        self.name = name
        self.colorHex = colorHex
        self.colorAlpha = colorAlpha
        self.radius = radius
        self.x = x
        self.y = y
    }
}
