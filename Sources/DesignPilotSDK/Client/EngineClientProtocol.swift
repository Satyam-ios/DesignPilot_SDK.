import Foundation

public struct EngineHealth: Codable, Sendable {
    public let isAlive: Bool
    public let version: String
    public let xcodeAvailable: Bool
    public let activeProject: String?

    public init(isAlive: Bool, version: String, xcodeAvailable: Bool, activeProject: String? = nil) {
        self.isAlive = isAlive
        self.version = version
        self.xcodeAvailable = xcodeAvailable
        self.activeProject = activeProject
    }
}

/// Abstract contract for interacting with the DesignPilot Generation Engine.
public protocol EngineClientProtocol: Sendable {
    /// Checks if the engine daemon is running and healthy.
    func checkHealth() async throws -> EngineHealth

    /// Validates URL reachability and Figma token access.
    func validateAccess(url: FigmaURL, token: String?) async throws -> Bool

    /// Executes the end-to-end design-to-code generation pipeline with streaming progress updates.
    func generate(
        request: GenerationRequest,
        onProgress: @Sendable @escaping (PipelineStage, Double, String) -> Void
    ) async throws -> GenerationResult

    /// Commits staged files into the target Xcode project.
    func integrate(request: IntegrationRequest) async throws -> IntegrationSummary

    /// Restores a previous backup snapshot.
    func rollback(backupId: String) async throws -> Bool
}
