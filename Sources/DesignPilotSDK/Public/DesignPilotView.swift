import SwiftUI

/// Ready-made DesignPilot developer view.
///
/// Simply add this view to any SwiftUI screen to automatically generate your complete application:
/// ```swift
/// import SwiftUI
/// import DesignPilotSDK
///
/// struct ContentView: View {
///     var body: some View {
///         DesignPilotView()
///     }
/// }
/// ```
public struct DesignPilotView: View {
    @StateObject private var viewModel: DesignPilotViewModel
    private let autoTrigger: Bool

    /// Initializes DesignPilotView reading configuration from `FigmaAppConfiguration`.
    public init() {
        var config = DesignPilotConfiguration.shared
        config.preferredFramework = (FigmaAppConfiguration.uiFramework == .uiKit) ? .uiKit : .swiftUI
        self._viewModel = StateObject(wrappedValue: DesignPilotViewModel(configuration: config))
        self.autoTrigger = FigmaAppConfiguration.autoGenerateOnLaunch && !FigmaAppConfiguration.figmaURL.isEmpty
    }

    /// Initializes DesignPilotView with an explicit Figma URL and UI Framework.
    public init(
        figmaURL: String,
        uiFramework: UIFramework = .automatic
    ) {
        FigmaAppConfiguration.figmaURL = figmaURL
        FigmaAppConfiguration.uiFramework = uiFramework
        var config = DesignPilotConfiguration.shared
        config.preferredFramework = (uiFramework == .uiKit) ? .uiKit : .swiftUI
        self._viewModel = StateObject(wrappedValue: DesignPilotViewModel(configuration: config))
        self.autoTrigger = !figmaURL.isEmpty
    }

    /// Initializes DesignPilotView with custom configuration.
    public init(configuration: DesignPilotConfiguration) {
        self._viewModel = StateObject(wrappedValue: DesignPilotViewModel(configuration: configuration))
        self.autoTrigger = false
    }

    /// Initializes DesignPilotView with an existing ViewModel (e.g. for testing).
    public init(viewModel: DesignPilotViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.autoTrigger = false
    }

    public var body: some View {
        DesignPilotContentView(viewModel: viewModel)
            .task {
                if autoTrigger && viewModel.state == .idle {
                    viewModel.urlInput = FigmaAppConfiguration.figmaURL
                    viewModel.generateUI()
                }
            }
    }
}

/// Convenience alias for automatic app generation.
public typealias DesignPilotAppView = DesignPilotView

struct DesignPilotView_Previews: PreviewProvider {
    static var previews: some View {
        DesignPilotView()
    }
}
