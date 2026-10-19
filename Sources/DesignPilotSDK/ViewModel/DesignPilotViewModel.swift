import SwiftUI
import Combine
import PDFKit

public enum DesignInputMode: String, CaseIterable, Identifiable, Sendable {
    case figmaURL = "Figma URL"
    case pdfUpload = "PDF Upload / Document"

    public var id: String { rawValue }
}

/// Main ViewModel coordinating the DesignPilot developer workflow for both Figma URLs and PDF designs.
@MainActor
public final class DesignPilotViewModel: ObservableObject {
    @Published public var inputMode: DesignInputMode = .figmaURL
    @Published public var urlInput: String = ""
    @Published public var pdfFilePathInput: String = ""
    @Published public var selectedPDFInfo: PDFSourceInfo? = nil
    @Published public var savedSource: DesignSource? = nil

    @Published public var state: GenerationState = .idle
    @Published public var currentStage: PipelineStage = .idle
    @Published public var progressValue: Double = 0.0
    @Published public var statusMessage: String = ""
    @Published public var lastResult: GenerationResult? = nil
    @Published public var lastIntegrationSummary: IntegrationSummary? = nil
    @Published public var engineHealth: EngineHealth? = nil
    @Published public var validationError: String? = nil
    @Published public var isReviewPresented: Bool = false
    @Published public var isSettingsPresented: Bool = false
    @Published public var isFileImporterPresented: Bool = false

    public let configuration: DesignPilotConfiguration
    private let client: EngineClientProtocol

    public var savedURL: FigmaURL? {
        savedSource?.figmaURL
    }

    public var savedPDF: PDFSourceInfo? {
        savedSource?.pdfInfo
    }

    /// Provides access to the latest or preset generation result.
    public var presetResult: GenerationResult? {
        if let last = lastResult {
            return last
        }
        return MockEngineClient.defaultPresetResult()
    }

    public init(
        configuration: DesignPilotConfiguration = .shared,
        client: EngineClientProtocol? = nil
    ) {
        self.configuration = configuration
        self.client = client ?? EngineHTTPClient(
            baseURL: configuration.daemonURL,
            executionMode: configuration.executionMode
        )

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
    public func saveURL() {
        validationError = nil
        do {
            let parsed = try FigmaURL.parse(urlInput)
            let source = DesignSource.figmaURL(parsed)
            self.savedSource = source
            self.state = .savedSource(source)
            self.statusMessage = "Figma URL saved successfully. Tap 'Generate UI' to proceed."
        } catch {
            self.validationError = error.localizedDescription
            self.statusMessage = "Validation failed."
        }
    }

    /// Saves the selected or typed PDF source without triggering generation.
    public func savePDFSource() {
        validationError = nil
        if let currentInfo = selectedPDFInfo {
            let source = DesignSource.pdf(currentInfo)
            self.savedSource = source
            self.state = .savedSource(source)
            self.statusMessage = "PDF '\(currentInfo.fileName)' saved (Page \(currentInfo.selectedPage) of \(currentInfo.pageCount)). Tap 'Generate UI' to proceed."
            return
        }

        let trimmedPath = pdfFilePathInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPath.isEmpty else {
            self.validationError = "Please select a PDF file or enter a valid file path."
            return
        }

        let url = URL(fileURLWithPath: trimmedPath)
        guard FileManager.default.fileExists(atPath: url.path) else {
            self.validationError = "File not found at: \(trimmedPath)"
            return
        }

        handleLoadedPDFURL(url)
    }

    /// Handles file selection from native file picker.
    public func handleFileImportResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }

            handleLoadedPDFURL(url)
        case .failure(let error):
            self.validationError = "File selection error: \(error.localizedDescription)"
        }
    }

    private func handleLoadedPDFURL(_ url: URL) {
        guard let doc = PDFDocument(url: url) else {
            self.validationError = "Failed to parse document as valid PDF."
            return
        }

        let totalPages = doc.pageCount
        let fileData = try? Data(contentsOf: url)
        let fileSize = fileData?.count ?? 0

        let info = PDFSourceInfo(
            filePath: url.path,
            fileName: url.lastPathComponent,
            pageCount: totalPages,
            selectedPage: 1,
            fileSizeInBytes: fileSize,
            fileData: fileData
        )

        self.selectedPDFInfo = info
        self.pdfFilePathInput = url.path
        let source = DesignSource.pdf(info)
        self.savedSource = source
        self.state = .savedSource(source)
        self.statusMessage = "Loaded '\(info.fileName)' (\(totalPages) pages, \(info.formattedFileSize))."
    }

    /// Selects a specific page of the loaded PDF.
    public func selectPDFPage(_ page: Int) {
        guard var info = selectedPDFInfo else { return }
        info = PDFSourceInfo(
            filePath: info.filePath,
            fileName: info.fileName,
            pageCount: info.pageCount,
            selectedPage: page,
            fileSizeInBytes: info.fileSizeInBytes,
            fileData: info.fileData
        )
        self.selectedPDFInfo = info
        self.savedSource = .pdf(info)
        self.statusMessage = "Selected page \(page) of \(info.pageCount)."
    }

    /// Validates and starts the end-to-end design-to-code generation workflow.
    public func generateUI() {
        validationError = nil
        let targetSource: DesignSource

        if inputMode == .figmaURL {
            do {
                let parsed = try FigmaURL.parse(urlInput)
                targetSource = .figmaURL(parsed)
                self.savedSource = targetSource
            } catch {
                self.validationError = error.localizedDescription
                self.state = .failed(.invalidURL(error.localizedDescription), retryStage: .validatingURL)
                return
            }
        } else {
            if let existing = selectedPDFInfo {
                targetSource = .pdf(existing)
            } else if !pdfFilePathInput.isEmpty {
                let url = URL(fileURLWithPath: pdfFilePathInput.trimmingCharacters(in: .whitespacesAndNewlines))
                if let doc = PDFDocument(url: url) {
                    let data = try? Data(contentsOf: url)
                    let info = PDFSourceInfo(
                        filePath: url.path,
                        fileName: url.lastPathComponent,
                        pageCount: doc.pageCount,
                        selectedPage: 1,
                        fileSizeInBytes: data?.count ?? 0,
                        fileData: data
                    )
                    self.selectedPDFInfo = info
                    targetSource = .pdf(info)
                } else {
                    self.validationError = "Unable to read PDF file at path."
                    self.state = .failed(.invalidPDF(pdfFilePathInput), retryStage: .validatingURL)
                    return
                }
            } else {
                self.validationError = "Please select a PDF file or enter a valid file path."
                self.state = .failed(.invalidPDF("No file provided"), retryStage: .validatingURL)
                return
            }
            self.savedSource = targetSource
        }

        let request = GenerationRequest(
            source: targetSource,
            preferredFramework: configuration.preferredFramework,
            targetDirectory: configuration.defaultTargetDirectory,
            visualAcceptanceThreshold: configuration.visualThreshold,
            maxVisualIterations: configuration.maxVisualIterations
        )

        Task {
            do {
                self.state = .inProgress(stage: .validatingURL, progress: 0.05, message: "Validating \(targetSource.displayName)...")
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
                self.statusMessage = "Application generated and running with \(result.visualDiff.similarityPercentageFormatted) visual match."
                self.isReviewPresented = false
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

    /// Convenience method to generate UI directly from the selected or configured PDF.
    public func generateUIFromPDF() {
        self.inputMode = .pdfUpload
        self.generateUI()
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
