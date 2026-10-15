import Foundation
import DesignPilotSDK

/// Parses Figma node trees into semantic AST layout elements.
public struct AutoLayoutParser: Sendable {
    public init() {}

    public func parse(rootNode: FigmaNode) -> ASTElement {
        return parseNode(rootNode)
    }

    private func parseNode(_ node: FigmaNode) -> ASTElement {
        let name = node.name

        // Check if Text node
        if node.nodeType == .text {
            let text = node.characters ?? "Text"
            let isHeading = (node.style?.fontSize ?? 14) >= 20
            var typo: TypographyToken? = nil
            if let style = node.style, let fontSize = style.fontSize {
                typo = TypographyToken(
                    name: "\(node.name)Font",
                    fontFamily: style.fontFamily ?? "SF Pro",
                    fontSize: fontSize,
                    fontWeight: weightName(style.fontWeight)
                )
            }
            let colorHex = extractFillHex(from: node.fills)
            return .text(characters: text, style: typo, colorHex: colorHex, isHeading: isHeading, name: name)
        }

        // Check if Button heuristic (Frame named "Button", "CTA", or containing button in name)
        let lowerName = name.lowercased()
        if (lowerName.contains("button") || lowerName.contains("cta")) && (node.children?.count ?? 0) <= 2 {
            let label = node.children?.first(where: { $0.nodeType == .text })?.characters ?? name
            let box = extractLayoutBox(from: node)
            return .button(title: label, box: box, actionName: "on\(sanitizeIdentifier(name))Tapped", name: name)
        }

        // Check if Vector or Image
        if node.nodeType == .vector || node.nodeType == .ellipse || lowerName.contains("icon") || lowerName.contains("image") {
            let systemIcon = matchSFSymbol(for: lowerName)
            let box = extractLayoutBox(from: node)
            return .image(assetName: sanitizeIdentifier(name), box: box, systemIcon: systemIcon, name: name)
        }

        // Check if Divider
        if (node.nodeType == .line || (node.absoluteBoundingBox?.height ?? 0) <= 2) && (node.children?.isEmpty ?? true) {
            return .divider
        }

        // Frame or Component Container
        let box = extractLayoutBox(from: node)
        let childrenElements = (node.children ?? []).compactMap { parseNode($0) }

        let layoutMode = node.layoutMode ?? "NONE"
        let spacing = node.itemSpacing ?? 8

        switch layoutMode {
        case "VERTICAL":
            let alignH: AlignmentHorizontal
            switch node.counterAxisAlignItems {
            case "CENTER": alignH = .center
            case "MAX": alignH = .trailing
            default: alignH = .leading
            }

            // Check if top-level screen frame that should scroll
            let isScreen = (node.absoluteBoundingBox?.height ?? 0) > 600 && lowerName.contains("screen") || lowerName.contains("view")
            if isScreen {
                let stack = ASTElement.container(
                    type: .verticalStack(spacing: spacing, alignment: alignH),
                    box: box,
                    children: childrenElements,
                    name: "\(name)Content"
                )
                return .container(type: .scrollContainer(axis: .vertical), box: box, children: [stack], name: name)
            }

            return .container(type: .verticalStack(spacing: spacing, alignment: alignH), box: box, children: childrenElements, name: name)

        case "HORIZONTAL":
            let alignV: AlignmentVertical
            switch node.counterAxisAlignItems {
            case "CENTER": alignV = .center
            case "MAX": alignV = .bottom
            case "BASELINE": alignV = .firstTextBaseline
            default: alignV = .top
            }
            return .container(type: .horizontalStack(spacing: spacing, alignment: alignV), box: box, children: childrenElements, name: name)

        default:
            return .container(type: .overlayStack(alignment: .center), box: box, children: childrenElements, name: name)
        }
    }

    private func extractLayoutBox(from node: FigmaNode) -> LayoutBox {
        var box = LayoutBox()

        // Sizing rules
        if let wRule = node.layoutSizingHorizontal {
            switch wRule {
            case "FIXED":
                if let w = node.absoluteBoundingBox?.width { box.width = .fixed(w) }
            case "FILL":
                box.width = .fill
            default:
                box.width = .hug
            }
        } else if let w = node.absoluteBoundingBox?.width, w > 0 {
            box.width = .fixed(w)
        }

        if let hRule = node.layoutSizingVertical {
            switch hRule {
            case "FIXED":
                if let h = node.absoluteBoundingBox?.height { box.height = .fixed(h) }
            case "FILL":
                box.height = .fill
            default:
                box.height = .hug
            }
        } else if let h = node.absoluteBoundingBox?.height, h > 0 {
            box.height = .fixed(h)
        }

        // Padding
        box.paddingTop = node.paddingTop ?? 0
        box.paddingRight = node.paddingRight ?? 0
        box.paddingBottom = node.paddingBottom ?? 0
        box.paddingLeft = node.paddingLeft ?? 0

        // Corner radius
        box.cornerRadius = node.cornerRadius ?? node.rectangleCornerRadii?.first ?? 0

        // Background color
        box.backgroundColorHex = extractFillHex(from: node.fills)

        // Effects / Shadows
        if let effects = node.effects {
            for effect in effects where effect.type == "DROP_SHADOW" && (effect.visible ?? true) {
                box.shadowRadius = effect.radius
                box.shadowOffset = (x: effect.offset?.x ?? 0, y: effect.offset?.y ?? 0)
                break
            }
        }

        return box
    }

    private func extractFillHex(from fills: [FigmaPaint]?) -> String? {
        guard let fills = fills else { return nil }
        for fill in fills where fill.type == "SOLID" && (fill.visible ?? true) {
            if let c = fill.color {
                let ri = Int(round(c.r * 255))
                let gi = Int(round(c.g * 255))
                let bi = Int(round(c.b * 255))
                return String(format: "#%02X%02X%02X", ri, gi, bi)
            }
        }
        return nil
    }

    private func weightName(_ weight: Double?) -> String {
        guard let w = weight else { return "Regular" }
        switch Int(w) {
        case ..<350: return "Light"
        case 350..<450: return "Regular"
        case 450..<600: return "Medium"
        case 600..<750: return "Semibold"
        default: return "Bold"
        }
    }

    private func matchSFSymbol(for name: String) -> String {
        if name.contains("arrow") { return "arrow.right" }
        if name.contains("search") { return "magnifyingglass" }
        if name.contains("user") || name.contains("profile") { return "person.crop.circle" }
        if name.contains("heart") { return "heart.fill" }
        if name.contains("star") { return "star.fill" }
        if name.contains("check") { return "checkmark" }
        if name.contains("close") || name.contains("xmark") { return "xmark" }
        if name.contains("bell") { return "bell.fill" }
        if name.contains("gear") || name.contains("setting") { return "gearshape.fill" }
        return "square.fill"
    }

    private func sanitizeIdentifier(_ str: String) -> String {
        let cleaned = str.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        return cleaned.isEmpty ? "View" : cleaned
    }
}
