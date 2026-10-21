import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Target UI rendering framework selected by the developer or detected automatically from the target project.
/// Compatible with Swift, SwiftUI, UIKit, and Objective-C projects.
@objc(DPUIFramework)
public enum DPUIFramework: Int, Codable, Sendable, CaseIterable {
    /// Inspects the host project architecture to automatically select SwiftUI or UIKit.
    case automatic = 0
    /// Generates pure SwiftUI views, `@Observable` ViewModels, and `NavigationStack` routing.
    case swiftUI = 1
    /// Generates UIKit view controllers, AutoLayout constraints, and `UITabBarController` / `UINavigationController`.
    case uiKit = 2

    public var title: String {
        switch self {
        case .automatic: return "Automatic"
        case .swiftUI: return "SwiftUI"
        case .uiKit: return "UIKit"
        }
    }
}

public typealias UIFramework = DPUIFramework

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

    /// Optional explicit project root path override. If nil, automatically discovered from project files.
    nonisolated(unsafe) public static var projectRootPath: String? = nil

    /// Discovered or configured caller source file path.
    nonisolated(unsafe) public static var configuredCallerFilePath: String? = nil

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

/// Global convenience entry point for DesignPilot configuration across Swift, SwiftUI, UIKit, and Objective-C.
@objc(DPDesignPilot)
public final class DesignPilot: NSObject {
    /// Objective-C and UIKit convenience configuration entry point.
    @objc(configureWithFigmaURL:uiFramework:autoGenerateOnLaunch:)
    public static func configure(
        figmaURL: String,
        uiFramework: DPUIFramework = .automatic,
        autoGenerateOnLaunch: Bool = true
    ) {
        configure(
            figmaURL: figmaURL,
            uiFramework: uiFramework,
            figmaAccessToken: nil,
            autoGenerateOnLaunch: autoGenerateOnLaunch,
            isGenerationBootstrapEnabled: nil
        )
    }

    /// Full Swift configuration entry point.
    /// The developer-provided URL always takes precedence over any default, cached, or previously stored URL.
    /// - Parameters:
    ///   - figmaURL: The Figma design URL to convert into a working iOS application.
    ///   - uiFramework: The preferred UI framework (.automatic, .swiftUI, or .uiKit).
    ///   - figmaAccessToken: Optional Figma personal access token for private designs.
    ///   - autoGenerateOnLaunch: Whether to generate and launch automatically on app launch.
    ///   - isGenerationBootstrapEnabled: Optional flag to explicitly enable or disable generation bootstrap.
    ///   - projectRootPath: Optional explicit project root path override.
    ///   - callerFilePath: Automatically captured caller source file path used to discover target project.
    public static func configure(
        figmaURL: String,
        uiFramework: UIFramework = .automatic,
        figmaAccessToken: String? = nil,
        autoGenerateOnLaunch: Bool = true,
        isGenerationBootstrapEnabled: Bool? = nil,
        projectRootPath: String? = nil,
        callerFilePath: StaticString = #filePath
    ) {
        let previousURL = UserDefaults.standard.string(forKey: FigmaAppConfiguration.lastConfiguredURLKey)
        let isDifferentURL = (previousURL != nil && !previousURL!.isEmpty && previousURL != figmaURL)
        UserDefaults.standard.set(figmaURL, forKey: FigmaAppConfiguration.lastConfiguredURLKey)

        FigmaAppConfiguration.figmaURL = figmaURL
        FigmaAppConfiguration.uiFramework = uiFramework
        FigmaAppConfiguration.figmaAccessToken = figmaAccessToken
        FigmaAppConfiguration.autoGenerateOnLaunch = autoGenerateOnLaunch
        if let root = projectRootPath {
            FigmaAppConfiguration.projectRootPath = root
        }
        FigmaAppConfiguration.configuredCallerFilePath = "\(callerFilePath)"

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

        #if canImport(UIKit)
        if autoGenerateOnLaunch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                autoPresentIfPossible()
            }
        }
        #endif
    }

    /// Clears any cached runtime URL and bootstrap state to ensure a fresh generation run.
    @objc public static func resetStoredConfiguration() {
        FigmaAppConfiguration.resetStoredConfiguration()
        #if canImport(UIKit)
        isAutoPresenting = false
        #endif
    }
}

#if canImport(UIKit)
extension DesignPilot {
    nonisolated(unsafe) private static var isAutoPresenting: Bool = false

    /// Finds the top-most active UIViewController in the active window scene.
    @MainActor
    public static func topMostViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseVC: UIViewController? = base ?? {
            let activeScenes = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }
            let scene = activeScenes.first ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
            return scene?.windows.first(where: { $0.isKeyWindow })?.rootViewController
                ?? scene?.windows.first?.rootViewController
        }()

        if let nav = baseVC as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = baseVC as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topMostViewController(base: selected)
            }
        }
        if let presented = baseVC?.presentedViewController, !presented.isBeingDismissed {
            return topMostViewController(base: presented)
        }
        return baseVC
    }

    /// Creates a UIViewController hosting the DesignPilot generation and preview interface.
    /// Compatible with UIKit (Swift & Objective-C).
    @MainActor
    @objc(makeViewControllerWithFigmaURL:uiFramework:)
    public static func makeViewController(
        figmaURL: String? = nil,
        uiFramework: DPUIFramework = .automatic
    ) -> UIViewController {
        let url = figmaURL ?? FigmaAppConfiguration.figmaURL
        let view = DesignPilotView(figmaURL: url, uiFramework: uiFramework)
        return UIHostingController(rootView: view)
    }

    /// Presents DesignPilot modal interface from any UIViewController in Swift or Objective-C.
    @MainActor
    @objc(presentFromViewController:figmaURL:uiFramework:animated:completion:)
    public static func present(
        from presenter: UIViewController,
        figmaURL: String? = nil,
        uiFramework: DPUIFramework = .automatic,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        let controller = makeViewController(figmaURL: figmaURL, uiFramework: uiFramework)
        controller.modalPresentationStyle = .fullScreen
        presenter.present(controller, animated: animated, completion: completion)
    }

    /// Automatically presents DesignPilot from a UIViewController if autoGenerateOnLaunch is true.
    @MainActor
    @objc(autoPresentFromViewController:)
    public static func autoPresentIfEnabled(from presenter: UIViewController) {
        guard FigmaAppConfiguration.autoGenerateOnLaunch && !FigmaAppConfiguration.figmaURL.isEmpty else { return }
        guard !isAutoPresenting else { return }
        guard !(presenter.presentedViewController is UIHostingController<DesignPilotView>) else { return }
        isAutoPresenting = true
        present(from: presenter, animated: true) {
            isAutoPresenting = false
        }
    }

    /// Automatically detects key window and presents DesignPilot if autoGenerateOnLaunch is true.
    @MainActor
    @objc(autoPresentIfPossible)
    public static func autoPresentIfPossible() {
        guard FigmaAppConfiguration.autoGenerateOnLaunch && !FigmaAppConfiguration.figmaURL.isEmpty else { return }
        guard !isAutoPresenting else { return }
        guard let topVC = topMostViewController(), !(topVC is UIHostingController<DesignPilotView>) else { return }
        isAutoPresenting = true
        present(from: topVC, animated: true) {
            isAutoPresenting = false
        }
    }
}
#endif
