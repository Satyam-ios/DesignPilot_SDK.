import Foundation
import DesignPilotSDK

public enum ProjectUIFramework: String, Codable, Sendable {
    case swiftUI = "SwiftUI"
    case uiKit = "UIKit"
    case hybrid = "Hybrid"
}

public struct DiscoveredSimulator: Codable, Sendable, Identifiable {
    public var id: String { udid }
    public let name: String
    public let udid: String
    public let osVersion: String
    public let isAvailable: Bool

    public init(name: String, udid: String, osVersion: String, isAvailable: Bool = true) {
        self.name = name
        self.udid = udid
        self.osVersion = osVersion
        self.isAvailable = isAvailable
    }
}

/// Discovered architecture, conventions, and capabilities of the target Xcode project.
public struct ProjectArchitecture: Codable, Sendable {
    public let projectName: String
    public let projectRootPath: String
    public let minDeploymentTarget: String
    public let swiftVersion: String
    public let primaryFramework: ProjectUIFramework
    public let existingViewsDirectory: String?
    public let assetCatalogPaths: [String]
    public let supportedDeviceFamilies: [String] // e.g. ["iPhone", "iPad"]
    public let availableSimulators: [DiscoveredSimulator]

    public init(
        projectName: String,
        projectRootPath: String,
        minDeploymentTarget: String = "16.0",
        swiftVersion: String = "6.0",
        primaryFramework: ProjectUIFramework = .swiftUI,
        existingViewsDirectory: String? = nil,
        assetCatalogPaths: [String] = [],
        supportedDeviceFamilies: [String] = ["iPhone", "iPad"],
        availableSimulators: [DiscoveredSimulator] = []
    ) {
        self.projectName = projectName
        self.projectRootPath = projectRootPath
        self.minDeploymentTarget = minDeploymentTarget
        self.swiftVersion = swiftVersion
        self.primaryFramework = primaryFramework
        self.existingViewsDirectory = existingViewsDirectory
        self.assetCatalogPaths = assetCatalogPaths
        self.supportedDeviceFamilies = supportedDeviceFamilies
        self.availableSimulators = availableSimulators
    }
}
