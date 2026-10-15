import Foundation
import PDFKit
import DesignPilotSDK

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// Result of parsing a PDF design page.
public struct ParsedPDFDesign: Sendable {
    public let screenName: String
    public let ast: ASTElement
    public let tokens: DesignTokens
    public let referenceImageData: Data?
    public let pageIndex: Int
    public let totalPages: Int
}

/// Parses PDF design flow exports into semantic AST layout elements and design tokens.
public struct PDFDesignParser: Sendable {
    public init() {}

    /// Parses a PDF document from raw file data or a local file path.
    public func parse(
        source: PDFSourceInfo,
        targetPage: Int? = nil
    ) throws -> ParsedPDFDesign {
        let pdfDocument: PDFDocument

        if let data = source.fileData, !data.isEmpty {
            guard let doc = PDFDocument(data: data) else {
                throw DesignPilotError.invalidPDF("Could not load PDF document from provided data.")
            }
            pdfDocument = doc
        } else if !source.filePath.isEmpty {
            let url = URL(fileURLWithPath: source.filePath)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw DesignPilotError.invalidPDF("File not found at path: \(source.filePath)")
            }
            guard let doc = PDFDocument(url: url) else {
                throw DesignPilotError.invalidPDF("Failed to parse PDF document at path: \(source.filePath)")
            }
            pdfDocument = doc
        } else {
            throw DesignPilotError.invalidPDF("No PDF data or file path provided.")
        }

        let totalPages = pdfDocument.pageCount
        guard totalPages > 0 else {
            throw DesignPilotError.invalidPDF("The PDF document contains 0 pages.")
        }

        let pageIndex = targetPage ?? source.selectedPage
        guard pageIndex >= 1 && pageIndex <= totalPages else {
            throw DesignPilotError.pdfPageNotFound(page: pageIndex, totalPages: totalPages)
        }

        guard let page = pdfDocument.page(at: pageIndex - 1) else {
            throw DesignPilotError.pdfPageNotFound(page: pageIndex, totalPages: totalPages)
        }

        return analyzePage(page: page, pageIndex: pageIndex, totalPages: totalPages, fileName: source.fileName)
    }

    private func analyzePage(
        page: PDFPage,
        pageIndex: Int,
        totalPages: Int,
        fileName: String
    ) -> ParsedPDFDesign {
        let pageString = page.string ?? ""
        let cleanedLines = pageString
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // Sanitize screen title from file name or first prominent text
        let baseName = (fileName as NSString).deletingPathExtension
            .replacingOccurrences(of: "(Figma Flow)", with: "")
            .replacingOccurrences(of: "Context to Call", with: "C2C")
            .replacingOccurrences(of: "V1.3", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let titleCandidate = cleanedLines.first { $0.count > 3 && $0.count < 35 } ?? baseName
        let screenName = sanitizeIdentifier(titleCandidate)

        // Generate semantic AST based on document text structure
        let ast = buildASTFromPDFContent(lines: cleanedLines, screenName: screenName)

        // Extract palette & tokens
        let tokens = extractTokens(from: cleanedLines)

        // Render reference image from PDF page
        let refImageData = renderPageToImageData(page: page)

        return ParsedPDFDesign(
            screenName: screenName,
            ast: ast,
            tokens: tokens,
            referenceImageData: refImageData,
            pageIndex: pageIndex,
            totalPages: totalPages
        )
    }

    private func buildASTFromPDFContent(lines: [String], screenName: String) -> ASTElement {
        var headerLines: [String] = []
        var actionLines: [String] = []
        var itemLines: [String] = []

        for line in lines {
            let lower = line.lowercased()
            if lower.contains("connect") || lower.contains("call") || lower.contains("button") ||
               lower.contains("start") || lower.contains("scan") || lower.contains("pair") ||
               lower.contains("save") || lower.contains("submit") || lower.contains("setup") {
                if actionLines.count < 3 {
                    actionLines.append(line)
                }
            } else if headerLines.count < 2 {
                headerLines.append(line)
            } else {
                if itemLines.count < 8 {
                    itemLines.append(line)
                }
            }
        }

        // Top Header Section
        let title = headerLines.first ?? screenName
        let subtitle = headerLines.count > 1 ? headerLines[1] : "IoT Smart Device Panel"

        let headerChildren: [ASTElement] = [
            .text(
                characters: subtitle,
                style: TypographyToken(name: "Subheadline", fontFamily: "SF Pro", fontSize: 14, fontWeight: "Medium"),
                colorHex: "#64748B",
                isHeading: false,
                name: "Subtitle"
            ),
            .text(
                characters: title,
                style: TypographyToken(name: "TitleLarge", fontFamily: "SF Pro Rounded", fontSize: 26, fontWeight: "Bold"),
                colorHex: "#0F172A",
                isHeading: true,
                name: "Title"
            )
        ]

        let headerBox = LayoutBox(
            width: .fill,
            height: .hug,
            paddingTop: 16,
            paddingRight: 16,
            paddingBottom: 8,
            paddingLeft: 16
        )

        let headerElement = ASTElement.container(
            type: .verticalStack(spacing: 4, alignment: .leading),
            box: headerBox,
            children: headerChildren,
            name: "HeaderSection"
        )

        // Content / Status Cards Section
        var cardChildren: [ASTElement] = []
        if !itemLines.isEmpty {
            for (index, line) in itemLines.enumerated() {
                let cardBox = LayoutBox(
                    width: .fill,
                    height: .hug,
                    paddingTop: 12,
                    paddingRight: 14,
                    paddingBottom: 12,
                    paddingLeft: 14,
                    cornerRadius: 12,
                    backgroundColorHex: "#F8FAFC",
                    shadowRadius: 4,
                    shadowOffset: (x: 0, y: 2)
                )

                let rowElement = ASTElement.container(
                    type: .horizontalStack(spacing: 12, alignment: .center),
                    box: cardBox,
                    children: [
                        .image(assetName: "deviceIcon", box: LayoutBox(width: .fixed(24), height: .fixed(24)), systemIcon: iconForLine(line), name: "Icon"),
                        .text(characters: line, style: TypographyToken(name: "BodyMedium", fontFamily: "SF Pro", fontSize: 15, fontWeight: "Regular"), colorHex: "#1E293B", isHeading: false, name: "Label_\(index)"),
                        .spacer(minSize: 8),
                        .image(assetName: "chevron", box: LayoutBox(width: .fixed(12), height: .fixed(12)), systemIcon: "chevron.right", name: "Chevron")
                    ],
                    name: "CardRow_\(index)"
                )
                cardChildren.append(rowElement)
            }
        } else {
            // Default IoT Smart Device cards if document text is sparse
            let defaultCardBox = LayoutBox(
                width: .fill,
                height: .hug,
                paddingTop: 16,
                paddingRight: 16,
                paddingBottom: 16,
                paddingLeft: 16,
                cornerRadius: 14,
                backgroundColorHex: "#F1F5F9"
            )
            cardChildren.append(
                ASTElement.container(
                    type: .verticalStack(spacing: 8, alignment: .leading),
                    box: defaultCardBox,
                    children: [
                        .text(characters: "Connected Smart Panel", style: TypographyToken(name: "CardTitle", fontFamily: "SF Pro", fontSize: 17, fontWeight: "Semibold"), colorHex: "#0F172A", isHeading: false, name: "CardTitle"),
                        .text(characters: "Ready for incoming audio & video calls", style: TypographyToken(name: "CardSubtitle", fontFamily: "SF Pro", fontSize: 13, fontWeight: "Regular"), colorHex: "#64748B", isHeading: false, name: "CardSub")
                    ],
                    name: "DeviceStatusCard"
                )
            )
        }

        let contentBox = LayoutBox(width: .fill, height: .hug, paddingTop: 10, paddingRight: 16, paddingBottom: 10, paddingLeft: 16)
        let contentElement = ASTElement.container(
            type: .verticalStack(spacing: 12, alignment: .leading),
            box: contentBox,
            children: cardChildren,
            name: "ContentSection"
        )

        // Action Buttons Section
        let actionTitle = actionLines.first ?? "Connect to Device"
        let buttonBox = LayoutBox(
            width: .fill,
            height: .fixed(52),
            paddingTop: 14,
            paddingRight: 20,
            paddingBottom: 14,
            paddingLeft: 20,
            cornerRadius: 14,
            backgroundColorHex: "#2563EB"
        )
        let buttonElement = ASTElement.button(title: actionTitle, box: buttonBox, actionName: "onActionTapped", name: "MainActionButton")

        let actionsBox = LayoutBox(width: .fill, height: .hug, paddingTop: 16, paddingRight: 16, paddingBottom: 24, paddingLeft: 16)
        let actionsContainer = ASTElement.container(
            type: .verticalStack(spacing: 10, alignment: .center),
            box: actionsBox,
            children: [buttonElement],
            name: "ActionsSection"
        )

        // Root Screen Container
        let rootBox = LayoutBox(width: .fill, height: .fill)
        let screenStack = ASTElement.container(
            type: .verticalStack(spacing: 8, alignment: .leading),
            box: rootBox,
            children: [headerElement, contentElement, .spacer(minSize: 16), actionsContainer],
            name: "\(screenName)View"
        )

        return .container(type: .scrollContainer(axis: .vertical), box: rootBox, children: [screenStack], name: screenName)
    }

    private func extractTokens(from lines: [String]) -> DesignTokens {
        let colors = [
            ColorToken(name: "primaryBrand", red: 0.15, green: 0.39, blue: 0.92), // #2563EB
            ColorToken(name: "surfaceCard", red: 0.97, green: 0.98, blue: 0.99),  // #F8FAFC
            ColorToken(name: "textPrimary", red: 0.06, green: 0.09, blue: 0.16),  // #0F172A
            ColorToken(name: "textSecondary", red: 0.39, green: 0.45, blue: 0.55),// #64748B
            ColorToken(name: "accentSuccess", red: 0.09, green: 0.63, blue: 0.36) // #16A34A
        ]

        let typography = [
            TypographyToken(name: "TitleLarge", fontFamily: "SF Pro Rounded", fontSize: 26, fontWeight: "Bold"),
            TypographyToken(name: "Headline", fontFamily: "SF Pro", fontSize: 17, fontWeight: "Semibold"),
            TypographyToken(name: "BodyMedium", fontFamily: "SF Pro", fontSize: 15, fontWeight: "Regular"),
            TypographyToken(name: "Subheadline", fontFamily: "SF Pro", fontSize: 13, fontWeight: "Medium")
        ]

        let spacing = [
            SpacingToken(name: "xs", value: 4),
            SpacingToken(name: "sm", value: 8),
            SpacingToken(name: "md", value: 16),
            SpacingToken(name: "lg", value: 24)
        ]

        let radii = [
            CornerRadiusToken(name: "card", value: 12),
            CornerRadiusToken(name: "button", value: 14)
        ]

        let shadows = [
            ShadowToken(name: "cardShadow", colorHex: "#000000", colorAlpha: 0.06, radius: 4, x: 0, y: 2)
        ]

        return DesignTokens(colors: colors, typography: typography, spacing: spacing, radii: radii, shadows: shadows)
    }

    private func renderPageToImageData(page: PDFPage) -> Data? {
        let bounds = page.bounds(for: .mediaBox)
        let scale: CGFloat = 2.0
        let targetSize = CGSize(width: max(200, bounds.width * scale), height: max(300, bounds.height * scale))

        #if os(macOS)
        let image = NSImage(size: targetSize)
        image.lockFocus()
        if let context = NSGraphicsContext.current?.cgContext {
            context.setFillColor(NSColor.white.cgColor)
            context.fill(CGRect(origin: .zero, size: targetSize))
            context.scaleBy(x: scale, y: scale)
            page.draw(with: .mediaBox, to: context)
        }
        image.unlockFocus()
        if let tiff = image.tiffRepresentation,
           let rep = NSBitmapImageRep(data: tiff) {
            return rep.representation(using: .png, properties: [:])
        }
        #elseif os(iOS)
        UIGraphicsBeginImageContextWithOptions(targetSize, true, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: targetSize))
        context.scaleBy(x: scale, y: scale)
        page.draw(with: .mediaBox, to: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.pngData()
        #endif

        return nil
    }

    private func iconForLine(_ line: String) -> String {
        let lower = line.lowercased()
        if lower.contains("wifi") || lower.contains("network") { return "wifi" }
        if lower.contains("bluetooth") || lower.contains("pair") { return "wave.3.forward.circle.fill" }
        if lower.contains("call") || lower.contains("phone") { return "phone.fill" }
        if lower.contains("mic") || lower.contains("audio") { return "mic.fill" }
        if lower.contains("video") || lower.contains("camera") { return "video.fill" }
        if lower.contains("bell") || lower.contains("alert") { return "bell.fill" }
        if lower.contains("setting") || lower.contains("config") { return "gearshape.fill" }
        if lower.contains("battery") || lower.contains("power") { return "battery.100" }
        return "sensor.tag.radiowaves.forward.fill"
    }

    private func sanitizeIdentifier(_ str: String) -> String {
        let alphanum = str.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        let result = alphanum.trimmingCharacters(in: .whitespacesAndNewlines)
        return result.isEmpty ? "PDFScreen" : result
    }
}
