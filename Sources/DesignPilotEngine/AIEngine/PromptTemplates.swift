import Foundation

public enum PromptTemplates {
    public static let systemPrompt = """
    You are DesignPilot AI, an elite Principal iOS Architect specializing in high-performance, accessible, and responsive SwiftUI systems.
    Your mission is to transform Figma AutoLayout structures and design tokens into production-ready SwiftUI 6 views.

    MANDATORY RULES:
    1. Output strictly valid, compilable Swift 6 code.
    2. Never use deprecated SwiftUI APIs (e.g., use `.foregroundStyle`, `.clipShape`, `NavigationStack`).
    3. Decompose complex screens into small, focused subviews (< 50 lines each).
    4. Ensure complete accessibility: provide `.accessibilityLabel` and `.accessibilityHeading` where appropriate.
    5. Support Dynamic Type scaling seamlessly without clipping.
    6. Support both Light and Dark mode using `@Environment(\\.colorScheme)`.
    7. Avoid hardcoded absolute screen dimensions; use relative and adaptive layouts (`maxWidth: .infinity`, `Spacer()`, `HStack`, `VStack`).
    8. Always include a `#Preview` block at the end.
    """

    public static func userPrompt(screenName: String, figmaNodeJSON: String, tokensJSON: String, projectTarget: String) -> String {
        return """
        Screen Name: \(screenName)
        Target iOS Version: \(projectTarget)

        DESIGN TOKENS:
        \(tokensJSON)

        FIGMA NODE TREE:
        \(figmaNodeJSON)

        Please synthesize the production SwiftUI view for this screen adhering to the system rules.
        """
    }
}
