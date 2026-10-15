import SwiftUI
import Combine

/// Main ViewModel coordinating the DesignPilot developer workflow.
@MainActor
public final class DesignPilotViewModel: ObservableObject {
    @Published public var urlInput: String = ""
    @Published public var state: GenerationState = .idle
    @Published public var currentStage: PipelineStage = .idle
    @Published public var progressValue: Double = 0.0
    @Published public var statusMessage: String = ""
    @Published public var savedURL: FigmaURL? = nil
    @Published public var lastResult: GenerationResult? = nil
    @Published public var lastIntegrationSummary: IntegrationSummary? = nil
    @Published public var engineHealth: EngineHealth? = nil
    @Published public var validationError: String? = nil
    @Published public var isReviewPresented: Bool = false
    @Published public var isSettingsPresented: Bool = false

    public let configuration: DesignPilotConfiguration
    private let client: EngineClientProtocol

    public init(
        configuration: DesignPilotConfiguration = .shared,
        client: EngineClientProtocol? = nil
    ) {
        self.configuration = configuration
        self.client = client ?? EngineHTTPClient(
            baseURL: configuration.daemonURL,
            executionMode: configuration.executionMode
        )

        // Prepopulate with a helpful example if empty
        if urlInput.isEmpty {
            self.urlInput = "https://www.figma.com/design/d8QW90X7vLp/DesignPilot-iOS-Design-System?node-id=402-1200"
        }
    }

    /// Checks daemon connectivity.
    public func refreshEngineHealth() async {
        do {
            let health = try await client.checkHealth()
            self.engineHealth = health
        } catch {
            self.engineHealth = EngineHealth(isAlive: false, version: "Offline", xcodeAvailable: false)
        }
    }

    /// Saves the Figma URL without triggering generation.
    /// Fulfills Section 3 requirement: Clearly distinguish saving a URL from generating.
    public func saveURL() {
        validationError = nil
        do {
            let parsed = try FigmaURL.parse(urlInput)
            self.savedURL = parsed
            self.state = .saved(parsed)
            self.statusMessage = "Figma URL saved successfully. Tap 'Generate UI' to proceed."
        } catch {
            self.validationError = error.localizedDescription
            self.statusMessage = "Validation failed."
        }
    }

    /// Validates and starts the end-to-end design-to-code generation workflow.
    public func generateUI() {
        validationError = nil
        let targetURL: FigmaURL
        do {
            targetURL = try FigmaURL.parse(urlInput)
            self.savedURL = targetURL
        } catch {
            self.validationError = error.localizedDescription
            self.state = .failed(.invalidURL(error.localizedDescription), retryStage: .validatingURL)
            return
        }

        let request = GenerationRequest(
            figmaURL: targetURL,
            preferredFramework: configuration.preferredFramework,
            targetDirectory: configuration.defaultTargetDirectory,
            visualAcceptanceThreshold: configuration.visualThreshold,
            maxVisualIterations: configuration.maxVisualIterations
        )

        Task {
            do {
                self.state = .inProgress(stage: .validatingURL, progress: 0.05, message: "Starting pipeline...")
                self.currentStage = .validatingURL

                let result = try await client.generate(request: request) { [weak self] stage, progress, message in
                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        self.currentStage = stage
                        self.progressValue = progress
                        self.statusMessage = message
                        self.state = .inProgress(stage: stage, progress: progress, message: message)
                    }
                }

                self.lastResult = result
                self.state = .readyForReview(result)
                self.currentStage = .readyForReview
                self.progressValue = 1.0
                self.statusMessage = "Generated \(result.generatedFiles.count) files with \(result.visualDiff.similarityPercentageFormatted) visual match."
                self.isReviewPresented = true
            } catch let err as DesignPilotError {
                self.state = .failed(err, retryStage: self.currentStage)
                self.statusMessage = err.localizedDescription
            } catch {
                let wrapped = DesignPilotError.unknown(error.localizedDescription)
                self.state = .failed(wrapped, retryStage: self.currentStage)
                self.statusMessage = wrapped.localizedDescription
            }
        }
    }

    /// Integrates the approved generated files into the target Xcode project.
    public func integrateFiles(selectedFiles: [String]) {
        guard let result = lastResult else { return }

        let request = IntegrationRequest(
            resultId: result.id,
            selectedFiles: selectedFiles,
            createBackup: true,
            targetDirectory: configuration.defaultTargetDirectory
        )

        Task {
            do {
                self.state = .integrating(progress: 0.5)
                self.statusMessage = "Creating rollback point and committing files..."
                let summary = try await client.integrate(request: request)
                self.lastIntegrationSummary = summary
                self.state = .completed(summary)
                self.currentStage = .completed
                self.statusMessage = "Successfully integrated \(summary.addedFiles.count) file(s). Backup: \(summary.backupId)"
            } catch let err as DesignPilotError {
                self.state = .failed(err, retryStage: .integrating)
                self.statusMessage = err.localizedDescription
            } catch {
                let wrapped = DesignPilotError.unknown(error.localizedDescription)
                self.state = .failed(wrapped, retryStage: .integrating)
                self.statusMessage = wrapped.localizedDescription
            }
        }
    }

    /// Restores previous project state using the backup snapshot.
    public func rollbackLatest() {
        guard let summary = lastIntegrationSummary else { return }
        Task {
            do {
                let success = try await client.rollback(backupId: summary.backupId)
                if success {
                    self.statusMessage = "Project rolled back to snapshot \(summary.backupId)."
                    self.state = .idle
                } else {
                    self.statusMessage = "Rollback failed."
                }
            } catch {
                self.statusMessage = "Rollback error: \(error.localizedDescription)"
            }
        }
    }

    /// Resets the generation workflow.
    public func reset() {
        self.state = .idle
        self.currentStage = .idle
        self.progressValue = 0.0
        self.statusMessage = ""
        self.lastResult = nil
        self.validationError = nil
    }
}
