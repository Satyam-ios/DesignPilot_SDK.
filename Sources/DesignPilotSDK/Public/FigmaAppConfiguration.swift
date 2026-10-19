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
    /// The source Figma design URL to generate. Provided by developer at runtime.
    nonisolated(unsafe) public static var figmaURL: String = ""

    /// Preferred UI framework. Defaults to `.automatic` to match the target project.
    nonisolated(unsafe) public static var uiFramework: UIFramework = .automatic

    /// Optional Figma personal access token or OAuth credential for accessing private files.
    nonisolated(unsafe) public static var figmaAccessToken: String? = nil

    /// When true, the app automatically starts analysis, code generation, and launch immediately upon running.
    nonisolated(unsafe) public static var autoGenerateOnLaunch: Bool = true

    /// Controls whether the generation bootstrap (analysis loader and generation pipeline) runs on app launch.
    /// Default is true on first launch. Once code generation completes and files are written into the project,
    /// this can be disabled to launch the generated native UI directly with zero delay.
    nonisolated(unsafe) public static var isGenerationBootstrapEnabled: Bool {
        get {
            if let stored = UserDefaults.standard.object(forKey: bootstrapStorageKey) as? Bool {
                return stored
            }
            return _isGenerationBootstrapEnabled
        }
        set {
            _isGenerationBootstrapEnabled = newValue
            UserDefaults.standard.set(newValue, forKey: bootstrapStorageKey)
        }
    }

    nonisolated(unsafe) private static var _isGenerationBootstrapEnabled: Bool = true
    internal static let bootstrapStorageKey = "DesignPilot_isGenerationBootstrapEnabled"
    internal static let lastConfiguredURLKey = "DesignPilot_lastConfiguredURL"

    /// Disables the generation bootstrap to bypass the analysis loader and launch directly into the generated UI.
    public static func disableGenerationBootstrap() {
        isGenerationBootstrapEnabled = false
    }

    /// Re-enables the generation bootstrap to re-analyze the Figma design and regenerate UI files.
    public static func enableGenerationBootstrap() {
        isGenerationBootstrapEnabled = true
    }

    /// Clears any cached runtime URL and bootstrap state to ensure a fresh generation run.
    public static func resetStoredConfiguration() {
        UserDefaults.standard.removeObject(forKey: bootstrapStorageKey)
        UserDefaults.standard.removeObject(forKey: lastConfiguredURLKey)
        _isGenerationBootstrapEnabled = true
        figmaURL = ""
    }
}

/// Global convenience entry point for DesignPilot configuration.
public struct DesignPilot {
    /// Configures the automatic generation engine.
    /// The developer-provided URL always takes precedence over any default, cached, or previously stored URL.
    /// - Parameters:
    ///   - figmaURL: The Figma design URL to convert into a working iOS application.
    ///   - uiFramework: The preferred UI framework (.automatic, .swiftUI, or .uiKit).
    ///   - figmaAccessToken: Optional Figma personal access token for private designs.
    ///   - autoGenerateOnLaunch: Whether to generate and launch automatically on app launch.
    ///   - isGenerationBootstrapEnabled: Optional flag to explicitly enable or disable generation bootstrap.
    public static func configure(
        figmaURL: String,
        uiFramework: UIFramework = .automatic,
        figmaAccessToken: String? = nil,
        autoGenerateOnLaunch: Bool = true,
        isGenerationBootstrapEnabled: Bool? = nil
    ) {
        let previousURL = UserDefaults.standard.string(forKey: FigmaAppConfiguration.lastConfiguredURLKey)
        let isDifferentURL = (previousURL != nil && !previousURL!.isEmpty && previousURL != figmaURL)
        UserDefaults.standard.set(figmaURL, forKey: FigmaAppConfiguration.lastConfiguredURLKey)

        FigmaAppConfiguration.figmaURL = figmaURL
        FigmaAppConfiguration.uiFramework = uiFramework
        FigmaAppConfiguration.figmaAccessToken = figmaAccessToken
        FigmaAppConfiguration.autoGenerateOnLaunch = autoGenerateOnLaunch

        // If the developer provided a different URL at runtime, it must take precedence
        // over any previous completion or cached bootstrap state.
        if isDifferentURL {
            FigmaAppConfiguration.isGenerationBootstrapEnabled = true
        } else if let bootstrap = isGenerationBootstrapEnabled {
            FigmaAppConfiguration.isGenerationBootstrapEnabled = bootstrap
        }

        if let token = figmaAccessToken {
            DesignPilotConfiguration.shared.figmaAccessToken = token
        }
    }
}
