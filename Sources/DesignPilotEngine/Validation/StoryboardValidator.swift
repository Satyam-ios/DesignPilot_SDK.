import Foundation
import DesignPilotSDK

/// Result of Storyboard and Interface Builder outlet / action connection validation.
public struct StoryboardValidationReport: Sendable, Codable, Hashable {
    public let isValid: Bool
    public let verifiedOutletsCount: Int
    public let verifiedActionsCount: Int
    public let verifiedOutlets: [String]
    public let verifiedActions: [String]
    public let brokenConnections: [String]
    public let summary: String

    public init(
        isValid: Bool,
        verifiedOutletsCount: Int,
        verifiedActionsCount: Int,
        verifiedOutlets: [String],
        verifiedActions: [String],
        brokenConnections: [String],
        summary: String
    ) {
        self.isValid = isValid
        self.verifiedOutletsCount = verifiedOutletsCount
        self.verifiedActionsCount = verifiedActionsCount
        self.verifiedOutlets = verifiedOutlets
        self.verifiedActions = verifiedActions
        self.brokenConnections = brokenConnections
        self.summary = summary
    }
}

/// Validates Storyboard XML markup and verifies that all declared @IBOutlet and @IBAction
/// connections in Swift view controllers have valid, non-broken links in the Storyboard scenes.
public struct StoryboardValidator: Sendable {
    public init() {}

    /// Validates a Storyboard XML document against a collection of Swift view controller source strings.
    public func validate(storyboardXML: String, viewControllerSources: [String]) -> StoryboardValidationReport {
        var brokenConnections: [String] = []

        // 1. Verify XML structure is well-formed
        guard storyboardXML.contains("<document type=\"com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB\""),
              storyboardXML.contains("</document>") else {
            return StoryboardValidationReport(
                isValid: false,
                verifiedOutletsCount: 0,
                verifiedActionsCount: 0,
                verifiedOutlets: [],
                verifiedActions: [],
                brokenConnections: ["Invalid or corrupted Storyboard XML document structure."],
                summary: "Storyboard validation failed: root document tags missing."
            )
        }

        // 2. Extract XML Outlets: <outlet property="headerTitleLabel" destination="TITLE_LBL_ID" ... />
        let xmlOutlets = extractXMLOutlets(from: storyboardXML)

        // 3. Extract XML Actions: <action selector="searchButtonTapped:" destination="CATALOG_VC_ID" ... />
        let xmlActions = extractXMLActions(from: storyboardXML)

        // 4. Extract Swift Code @IBOutlet properties: @IBOutlet public weak var headerTitleLabel: UILabel!
        let swiftOutlets = viewControllerSources.flatMap { extractSwiftOutlets(from: $0) }

        // 5. Extract Swift Code @IBAction methods: @IBAction public func searchButtonTapped(
        let swiftActions = viewControllerSources.flatMap { extractSwiftActions(from: $0) }

        // 6. Verify each Swift @IBOutlet is connected in the XML
        var verifiedOutlets: [String] = []
        for outlet in swiftOutlets {
            if xmlOutlets.contains(where: { $0.propertyName == outlet }) {
                verifiedOutlets.append(outlet)
            } else {
                brokenConnections.append("Missing Storyboard connection for @IBOutlet '\(outlet)'")
            }
        }

        // 7. Verify each Swift @IBAction has a trigger in the XML
        var verifiedActions: [String] = []
        for action in swiftActions {
            let normalizedAction = action.hasSuffix(":") ? String(action.dropLast()) : action
            if xmlActions.contains(where: {
                let norm = $0.selectorName.hasSuffix(":") ? String($0.selectorName.dropLast()) : $0.selectorName
                return norm == normalizedAction
            }) {
                verifiedActions.append(action)
            } else {
                brokenConnections.append("Missing Storyboard connection for @IBAction '\(action)'")
            }
        }

        // 8. Check that destinations exist in the document
        for xmlOutlet in xmlOutlets {
            let destIdPattern = "id=\"\(xmlOutlet.destinationId)\""
            if !storyboardXML.contains(destIdPattern) {
                brokenConnections.append("Dangling outlet destination '\(xmlOutlet.destinationId)' for property '\(xmlOutlet.propertyName)'")
            }
        }

        let isValid = brokenConnections.isEmpty && !verifiedOutlets.isEmpty
        let summary = isValid
            ? "100% Verified: All \(verifiedOutlets.count) @IBOutlet and \(verifiedActions.count) @IBAction connections cleanly linked (0 broken)."
            : "Storyboard validation found \(brokenConnections.count) broken or missing connections."

        return StoryboardValidationReport(
            isValid: isValid,
            verifiedOutletsCount: verifiedOutlets.count,
            verifiedActionsCount: verifiedActions.count,
            verifiedOutlets: verifiedOutlets,
            verifiedActions: verifiedActions,
            brokenConnections: brokenConnections,
            summary: summary
        )
    }

    private func extractXMLOutlets(from xml: String) -> [StoryboardOutlet] {
        var outlets: [StoryboardOutlet] = []
        let pattern = "<outlet\\s+property=\"([^\"]+)\"\\s+destination=\"([^\"]+)\""
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsrange = NSRange(xml.startIndex..<xml.endIndex, in: xml)
            let matches = regex.matches(in: xml, options: [], range: nsrange)
            for match in matches {
                if let propRange = Range(match.range(at: 1), in: xml),
                   let destRange = Range(match.range(at: 2), in: xml) {
                    let prop = String(xml[propRange])
                    let dest = String(xml[destRange])
                    outlets.append(StoryboardOutlet(propertyName: prop, destinationId: dest, viewType: "UIView"))
                }
            }
        }
        return outlets
    }

    private func extractXMLActions(from xml: String) -> [StoryboardAction] {
        var actions: [StoryboardAction] = []
        let pattern = "<action\\s+selector=\"([^\"]+)\"\\s+destination=\"([^\"]+)\""
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsrange = NSRange(xml.startIndex..<xml.endIndex, in: xml)
            let matches = regex.matches(in: xml, options: [], range: nsrange)
            for match in matches {
                if let selRange = Range(match.range(at: 1), in: xml),
                   let destRange = Range(match.range(at: 2), in: xml) {
                    let sel = String(xml[selRange])
                    let dest = String(xml[destRange])
                    actions.append(StoryboardAction(selectorName: sel, destinationId: dest))
                }
            }
        }
        return actions
    }

    private func extractSwiftOutlets(from swiftCode: String) -> [String] {
        var outlets: [String] = []
        let lines = swiftCode.components(separatedBy: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("@IBOutlet") {
                // e.g. "@IBOutlet public weak var headerTitleLabel: UILabel!"
                if let varRange = trimmed.range(of: "var ") {
                    let afterVar = trimmed[varRange.upperBound...]
                    if let colonRange = afterVar.range(of: ":") {
                        let name = String(afterVar[..<colonRange.lowerBound]).trimmingCharacters(in: .whitespaces)
                        if !name.isEmpty {
                            outlets.append(name)
                        }
                    }
                }
            }
        }
        return outlets
    }

    private func extractSwiftActions(from swiftCode: String) -> [String] {
        var actions: [String] = []
        let lines = swiftCode.components(separatedBy: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("@IBAction") {
                // e.g. "@IBAction public func searchButtonTapped(_ sender: UIButton)"
                if let funcRange = trimmed.range(of: "func ") {
                    let afterFunc = trimmed[funcRange.upperBound...]
                    if let parenRange = afterFunc.range(of: "(") {
                        let name = String(afterFunc[..<parenRange.lowerBound]).trimmingCharacters(in: .whitespaces)
                        if !name.isEmpty {
                            actions.append(name)
                        }
                    }
                }
            }
        }
        return actions
    }
}
