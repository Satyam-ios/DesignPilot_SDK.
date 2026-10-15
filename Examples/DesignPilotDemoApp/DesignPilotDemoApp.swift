import SwiftUI
import DesignPilotSDK

@main
struct DesignPilotDemoApp: App {
    init() {
        // Optional SDK Configuration at app launch
        DesignPilotSDK.configure(
            DesignPilotConfiguration(
                executionMode: .auto,
                defaultTargetDirectory: "Views/Generated",
                preferredFramework: .swiftUI,
                visualThreshold: 0.95,
                maxVisualIterations: 3
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
