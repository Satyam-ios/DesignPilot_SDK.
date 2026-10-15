import Foundation

public enum ExecutionMode: String, Codable, Sendable, CaseIterable {
    /// Attempts to connect to the local macOS daemon first.
    /// If the daemon is not running, falls back gracefully to high-fidelity standalone demo mode.
    case auto = "Auto (Daemon with Demo Fallback)"
    /// Requires active connection to local macOS daemon (`designpilot daemon`).
    case daemonOnly = "Engine Daemon Only"
    /// Runs completely standalone without needing the daemon (ideal for previews and simulator demos).
    case standaloneDemo = "Standalone Demo Mode"
}

/// Configuration settings for the DesignPilot SDK.
public struct DesignPilotConfiguration: Sendable {
    public var daemonURL: URL
    public var executionMode: ExecutionMode
    public var defaultTargetDirectory: String
    public var preferredFramework: TargetFramework
    public var visualThreshold: Double
    public var maxVisualIterations: Int
    public var figmaAccessToken: String?
    public var autoSaveLastURL: Bool

    public static let defaultDaemonURL = URL(string: "http://127.0.0.1:8088")!

    public init(
        daemonURL: URL = DesignPilotConfiguration.defaultDaemonURL,
        executionMode: ExecutionMode = .auto,
        defaultTargetDirectory: String = "Views/Generated",
        preferredFramework: TargetFramework = .swiftUI,
        visualThreshold: Double = 0.95,
        maxVisualIterations: Int = 3,
        figmaAccessToken: String? = nil,
        autoSaveLastURL: Bool = true
    ) {
        self.daemonURL = daemonURL
        self.executionMode = executionMode
        self.defaultTargetDirectory = defaultTargetDirectory
        self.preferredFramework = preferredFramework
        self.visualThreshold = visualThreshold
        self.maxVisualIterations = maxVisualIterations
        self.figmaAccessToken = figmaAccessToken
        self.autoSaveLastURL = autoSaveLastURL
    }

    /// Default global configuration.
    nonisolated(unsafe) public static var shared = DesignPilotConfiguration()
}
