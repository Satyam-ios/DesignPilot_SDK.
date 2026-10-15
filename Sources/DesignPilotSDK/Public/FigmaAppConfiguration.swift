import Foundation

/// Target UI rendering framework selected by the developer or detected automatically from the target project.
public enum UIFramework: String, Codable, Sendable, CaseIterable {
    /// Inspects the host project architecture to automatically select SwiftUI or UIKit.
    case automatic = "Automatic"
    /// Generates pure SwiftUI views, `@Observable` ViewModels, and `NavigationStack` routing.
    case swiftUI = "SwiftUI"
    /// Generates UIKit view controllers, AutoLayout constraints, and `UITabBarController` / `UINavigationController`.
    case uiKit = "UIKit"
}

/// Central configuration for automatic Figma-to-iOS app generation.
/// Developers configure this once in code or project settings, and the library automatically
/// generates the complete multi-screen application on launch without manual URL entry.
public enum FigmaAppConfiguration {
    /// The source Figma design URL to generate.
    nonisolated(unsafe) public static var figmaURL: String = "https://www.figma.com/design/z3bsh0M4MFRN7HvwWuYT7e/Untitled?node-id=0-1&p=f&t=xR1XUFtfaCIbAGe2-0"

    /// Preferred UI framework. Defaults to `.automatic` to match the target project.
    nonisolated(unsafe) public static var uiFramework: UIFramework = .automatic

    /// When true, the app automatically starts analysis, code generation, and launch immediately upon running.
    nonisolated(unsafe) public static var autoGenerateOnLaunch: Bool = true
}

/// Global convenience entry point for DesignPilot configuration.
public struct DesignPilot {
    /// Configures the automatic generation engine.
    /// - Parameters:
    ///   - figmaURL: The Figma design URL to convert into a working iOS application.
    ///   - uiFramework: The preferred UI framework (.automatic, .swiftUI, or .uiKit).
    ///   - autoGenerateOnLaunch: Whether to generate and launch automatically on app launch.
    public static func configure(
        figmaURL: String,
        uiFramework: UIFramework = .automatic,
        autoGenerateOnLaunch: Bool = true
    ) {
        FigmaAppConfiguration.figmaURL = figmaURL
        FigmaAppConfiguration.uiFramework = uiFramework
        FigmaAppConfiguration.autoGenerateOnLaunch = autoGenerateOnLaunch
    }
}
