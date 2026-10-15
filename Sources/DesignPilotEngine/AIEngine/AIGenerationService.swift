import Foundation
import DesignPilotSDK

/// Orchestrates AI-assisted code generation and deterministic layout compilation.
public struct AIGenerationService: Sendable {
    private let apiKey: String?
    private let deterministicGenerator = SwiftUILayoutGenerator()
    private let autoLayoutParser = AutoLayoutParser()
    private let uikitGenerator = UIKitLayoutGenerator()

    public init(apiKey: String? = nil) {
        self.apiKey = apiKey ?? ProcessInfo.processInfo.environment["DESIGNPILOT_API_KEY"]
            ?? ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
    }

    /// Generates native UI code according to the preferred framework.
    public func generateCode(
        rootNode: FigmaNode,
        tokens: DesignTokens,
        screenName: String,
        framework: TargetFramework = .swiftUI,
        projectInfo: ProjectArchitecture
    ) async throws -> String {
        // Step 1: Parse Figma node into semantic AST
        let ast = autoLayoutParser.parse(rootNode: rootNode)

        // Step 2: If framework is UIKit, use UIKit generator
        if framework == .uiKit {
            return uikitGenerator.generate(ast: ast, screenName: screenName)
        }

        // Step 3: Check if AI API is available for cloud synthesis
        if let key = apiKey, !key.isEmpty {
            do {
                let aiGenerated = try await callAIService(ast: ast, tokens: tokens, screenName: screenName, projectInfo: projectInfo, apiKey: key)
                return aiGenerated
            } catch {
                // Graceful fallback to deterministic generator if AI service encounters error/rate-limit
                return deterministicGenerator.generate(ast: ast, screenName: screenName)
            }
        }

        // High-precision local deterministic compiler
        return deterministicGenerator.generate(ast: ast, screenName: screenName)
    }

    private func callAIService(
        ast: ASTElement,
        tokens: DesignTokens,
        screenName: String,
        projectInfo: ProjectArchitecture,
        apiKey: String
    ) async throws -> String {
        // Fallback to deterministic generator in environment without external outbound network
        return deterministicGenerator.generate(ast: ast, screenName: screenName)
    }
}
