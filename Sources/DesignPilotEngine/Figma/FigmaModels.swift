import Foundation
import DesignPilotSDK

// MARK: - Figma REST API Response Models

public struct FigmaFileResponse: Codable, Sendable {
    public let name: String
    public let lastModified: String
    public let document: FigmaNode
    public let components: [String: FigmaComponentMeta]?
    public let styles: [String: FigmaStyleMeta]?
}

public struct FigmaNodesResponse: Codable, Sendable {
    public let name: String
    public let lastModified: String
    public let nodes: [String: FigmaNodeContainer]
}

public struct FigmaNodeContainer: Codable, Sendable {
    public let document: FigmaNode
    public let components: [String: FigmaComponentMeta]?
    public let styles: [String: FigmaStyleMeta]?
}

public struct FigmaComponentMeta: Codable, Sendable {
    public let key: String
    public let name: String
    public let description: String?
}

public struct FigmaStyleMeta: Codable, Sendable {
    public let key: String
    public let name: String
    public let styleType: String?
}

// MARK: - Figma Node Tree Representation

public enum FigmaNodeType: String, Codable, Sendable {
    case document = "DOCUMENT"
    case canvas = "CANVAS"
    case frame = "FRAME"
    case group = "GROUP"
    case vector = "VECTOR"
    case booleanOperation = "BOOLEAN_OPERATION"
    case star = "STAR"
    case line = "LINE"
    case ellipse = "ELLIPSE"
    case regularPolygon = "REGULAR_POLYGON"
    case rectangle = "RECTANGLE"
    case text = "TEXT"
    case slice = "SLICE"
    case component = "COMPONENT"
    case componentSet = "COMPONENT_SET"
    case instance = "INSTANCE"
    case section = "SECTION"
    case unknown
}

public struct FigmaNode: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let type: String
    public let visible: Bool?
    public let children: [FigmaNode]?

    // Auto Layout & Box Geometry
    public let absoluteBoundingBox: FigmaRect?
    public let layoutMode: String? // "NONE", "HORIZONTAL", "VERTICAL"
    public let primaryAxisAlignItems: String? // "MIN", "CENTER", "MAX", "SPACE_BETWEEN"
    public let counterAxisAlignItems: String? // "MIN", "CENTER", "MAX", "BASELINE"
    public let layoutSizingHorizontal: String? // "FIXED", "HUG", "FILL"
    public let layoutSizingVertical: String? // "FIXED", "HUG", "FILL"
    public let itemSpacing: Double?
    public let counterAxisSpacing: Double?
    public let paddingLeft: Double?
    public let paddingRight: Double?
    public let paddingTop: Double?
    public let paddingBottom: Double?
    public let cornerRadius: Double?
    public let rectangleCornerRadii: [Double]?

    // Visual Styles
    public let fills: [FigmaPaint]?
    public let strokes: [FigmaPaint]?
    public let strokeWeight: Double?
    public let opacity: Double?
    public let effects: [FigmaEffect]?

    // Typography
    public let characters: String?
    public let style: FigmaTypeStyle?

    public init(
        id: String,
        name: String,
        type: String,
        visible: Bool? = true,
        children: [FigmaNode]? = nil,
        absoluteBoundingBox: FigmaRect? = nil,
        layoutMode: String? = nil,
        primaryAxisAlignItems: String? = nil,
        counterAxisAlignItems: String? = nil,
        layoutSizingHorizontal: String? = nil,
        layoutSizingVertical: String? = nil,
        itemSpacing: Double? = nil,
        counterAxisSpacing: Double? = nil,
        paddingLeft: Double? = nil,
        paddingRight: Double? = nil,
        paddingTop: Double? = nil,
        paddingBottom: Double? = nil,
        cornerRadius: Double? = nil,
        rectangleCornerRadii: [Double]? = nil,
        fills: [FigmaPaint]? = nil,
        strokes: [FigmaPaint]? = nil,
        strokeWeight: Double? = nil,
        opacity: Double? = nil,
        effects: [FigmaEffect]? = nil,
        characters: String? = nil,
        style: FigmaTypeStyle? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.visible = visible
        self.children = children
        self.absoluteBoundingBox = absoluteBoundingBox
        self.layoutMode = layoutMode
        self.primaryAxisAlignItems = primaryAxisAlignItems
        self.counterAxisAlignItems = counterAxisAlignItems
        self.layoutSizingHorizontal = layoutSizingHorizontal
        self.layoutSizingVertical = layoutSizingVertical
        self.itemSpacing = itemSpacing
        self.counterAxisSpacing = counterAxisSpacing
        self.paddingLeft = paddingLeft
        self.paddingRight = paddingRight
        self.paddingTop = paddingTop
        self.paddingBottom = paddingBottom
        self.cornerRadius = cornerRadius
        self.rectangleCornerRadii = rectangleCornerRadii
        self.fills = fills
        self.strokes = strokes
        self.strokeWeight = strokeWeight
        self.opacity = opacity
        self.effects = effects
        self.characters = characters
        self.style = style
    }

    public var nodeType: FigmaNodeType {
        FigmaNodeType(rawValue: type) ?? .unknown
    }
}

public struct FigmaRect: Codable, Sendable {
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

public struct FigmaPaint: Codable, Sendable {
    public let type: String // "SOLID", "GRADIENT_LINEAR", "IMAGE", etc.
    public let visible: Bool?
    public let opacity: Double?
    public let color: FigmaColor?
    public let gradientStops: [FigmaColorStop]?

    public init(
        type: String,
        visible: Bool? = true,
        opacity: Double? = 1.0,
        color: FigmaColor? = nil,
        gradientStops: [FigmaColorStop]? = nil
    ) {
        self.type = type
        self.visible = visible
        self.opacity = opacity
        self.color = color
        self.gradientStops = gradientStops
    }
}

public struct FigmaColor: Codable, Sendable {
    public let r: Double
    public let g: Double
    public let b: Double
    public let a: Double

    public init(r: Double, g: Double, b: Double, a: Double = 1.0) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
}

public struct FigmaColorStop: Codable, Sendable {
    public let position: Double
    public let color: FigmaColor

    public init(position: Double, color: FigmaColor) {
        self.position = position
        self.color = color
    }
}

public struct FigmaEffect: Codable, Sendable {
    public let type: String // "DROP_SHADOW", "INNER_SHADOW", "LAYER_BLUR", "BACKGROUND_BLUR"
    public let visible: Bool?
    public let radius: Double
    public let color: FigmaColor?
    public let offset: FigmaOffset?

    public init(
        type: String,
        visible: Bool? = true,
        radius: Double,
        color: FigmaColor? = nil,
        offset: FigmaOffset? = nil
    ) {
        self.type = type
        self.visible = visible
        self.radius = radius
        self.color = color
        self.offset = offset
    }
}

public struct FigmaOffset: Codable, Sendable {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public struct FigmaTypeStyle: Codable, Sendable {
    public let fontFamily: String?
    public let fontPostScriptName: String?
    public let fontWeight: Double?
    public let fontSize: Double?
    public let textAlignHorizontal: String? // "LEFT", "RIGHT", "CENTER", "JUSTIFIED"
    public let textAlignVertical: String? // "TOP", "CENTER", "BOTTOM"
    public let letterSpacing: Double?
    public let lineHeightPx: Double?

    public init(
        fontFamily: String? = nil,
        fontPostScriptName: String? = nil,
        fontWeight: Double? = nil,
        fontSize: Double? = nil,
        textAlignHorizontal: String? = nil,
        textAlignVertical: String? = nil,
        letterSpacing: Double? = nil,
        lineHeightPx: Double? = nil
    ) {
        self.fontFamily = fontFamily
        self.fontPostScriptName = fontPostScriptName
        self.fontWeight = fontWeight
        self.fontSize = fontSize
        self.textAlignHorizontal = textAlignHorizontal
        self.textAlignVertical = textAlignVertical
        self.letterSpacing = letterSpacing
        self.lineHeightPx = lineHeightPx
    }
}
