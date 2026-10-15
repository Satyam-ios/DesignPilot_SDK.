import Foundation

/// Primary facade for configuring and managing DesignPilot SDK runtime settings.
public enum DesignPilotSDK {
    /// The current semantic version of the SDK.
    public static let version = "1.0.0"

    /// Configures global SDK options.
    /// - Parameter configuration: The configuration options.
    public static func configure(_ configuration: DesignPilotConfiguration) {
        DesignPilotConfiguration.shared = configuration
    }
}
