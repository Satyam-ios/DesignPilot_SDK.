import Foundation
import DesignPilotSDK

/// Semantic Intermediate Representation (IR) node for mobile layout generation.
public enum LayoutContainerType: Sendable {
    case verticalStack(spacing: Double, alignment: AlignmentHorizontal)
    case horizontalStack(spacing: Double, alignment: AlignmentVertical)
    case overlayStack(alignment: AlignmentZ)
    case scrollContainer(axis: ScrollAxis)
}

public enum AlignmentHorizontal: String, Sendable {
    case leading, center, trailing
}

public enum AlignmentVertical: String, Sendable {
    case top, center, bottom, firstTextBaseline
}

public enum AlignmentZ: String, Sendable {
    case center, topLeading, bottomTrailing
}

public enum ScrollAxis: String, Sendable {
    case vertical, horizontal
}

public enum SizingRule: Sendable {
    case fixed(Double)
    case hug
    case fill
}

public struct LayoutBox: Sendable {
    public var width: SizingRule
    public var height: SizingRule
    public var paddingTop: Double
    public var paddingRight: Double
    public var paddingBottom: Double
    public var paddingLeft: Double
    public var cornerRadius: Double
    public var backgroundColorHex: String?
    public var backgroundAlpha: Double
    public var shadowRadius: Double?
    public var shadowOffset: (x: Double, y: Double)?

    public init(
        width: SizingRule = .hug,
        height: SizingRule = .hug,
        paddingTop: Double = 0,
        paddingRight: Double = 0,
        paddingBottom: Double = 0,
        paddingLeft: Double = 0,
        cornerRadius: Double = 0,
        backgroundColorHex: String? = nil,
        backgroundAlpha: Double = 1.0,
        shadowRadius: Double? = nil,
        shadowOffset: (x: Double, y: Double)? = nil
    ) {
        self.width = width
        self.height = height
        self.paddingTop = paddingTop
        self.paddingRight = paddingRight
        self.paddingBottom = paddingBottom
        self.paddingLeft = paddingLeft
        self.cornerRadius = cornerRadius
        self.backgroundColorHex = backgroundColorHex
        self.backgroundAlpha = backgroundAlpha
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
    }
}

public enum ASTElement: Sendable {
    case container(type: LayoutContainerType, box: LayoutBox, children: [ASTElement], name: String)
    case text(characters: String, style: TypographyToken?, colorHex: String?, isHeading: Bool, name: String)
    case button(title: String, box: LayoutBox, actionName: String, name: String)
    case image(assetName: String, box: LayoutBox, systemIcon: String?, name: String)
    case spacer(minSize: Double?)
    case divider
}
