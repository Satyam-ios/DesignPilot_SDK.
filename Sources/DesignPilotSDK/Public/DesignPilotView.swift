import SwiftUI

/// Ready-made DesignPilot developer interface view.
///
/// Simply add this view to any SwiftUI screen to enable instant Figma-to-Xcode UI generation:
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

    /// Initializes DesignPilotView with default configuration.
    public init() {
        self._viewModel = StateObject(wrappedValue: DesignPilotViewModel(configuration: .shared))
    }

    /// Initializes DesignPilotView with custom configuration.
    public init(configuration: DesignPilotConfiguration) {
        self._viewModel = StateObject(wrappedValue: DesignPilotViewModel(configuration: configuration))
    }

    /// Initializes DesignPilotView with an existing ViewModel (e.g. for testing).
    public init(viewModel: DesignPilotViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        DesignPilotContentView(viewModel: viewModel)
    }
}

#Preview {
    DesignPilotView()
}
