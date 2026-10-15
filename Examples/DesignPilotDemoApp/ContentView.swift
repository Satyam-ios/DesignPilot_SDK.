import SwiftUI
import DesignPilotSDK

/// Example developer application screen showcasing DesignPilot integration.
///
/// As simple as:
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
public struct ContentView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            DesignPilotView()
                .navigationTitle("DesignPilot SDK")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
        }
    }
}

#Preview {
    ContentView()
}
