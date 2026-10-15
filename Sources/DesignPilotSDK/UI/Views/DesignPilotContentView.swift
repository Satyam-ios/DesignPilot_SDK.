import SwiftUI

/// Main container view rendering the DesignPilot developer interface.
public struct DesignPilotContentView: View {
    @ObservedObject public var viewModel: DesignPilotViewModel

    public init(viewModel: DesignPilotViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerBar
                urlInputCard
                actionButtonsSection
                statusAndProgressSection
            }
            .padding(16)
        }
        .background(Color.dpSystemBackground)
        .sheet(isPresented: $viewModel.isSettingsPresented) {
            SettingsSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.isReviewPresented) {
            if let result = viewModel.lastResult {
                ReviewIntegrationSheet(result: result) { selectedFiles in
                    viewModel.integrateFiles(selectedFiles: Array(selectedFiles))
                }
            }
        }
        .task {
            await viewModel.refreshEngineHealth()
        }
    }

    private var headerBar: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("DesignPilot")
                        .font(.title3.weight(.bold))
                    Text("SDK")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.15))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
                Text("AI-Powered Figma-to-Xcode UI Generator")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: { viewModel.isSettingsPresented = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(Color.dpSecondaryBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var urlInputCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Figma Design URL")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if let saved = viewModel.savedURL {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 11))
                        Text("Saved (Key: \(String(saved.fileKey.prefix(6)))...)")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "link")
                    .foregroundColor(.blue)
                    .font(.system(size: 14))

                TextField("https://www.figma.com/design/:key/:title?node-id=...", text: $viewModel.urlInput)
                    .font(.system(size: 13, design: .monospaced))
                    .autocorrectionDisabled()
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    #endif

                if !viewModel.urlInput.isEmpty {
                    Button(action: { viewModel.urlInput = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                }

                Button(action: pasteFromClipboard) {
                    HStack(spacing: 3) {
                        Image(systemName: "doc.on.clipboard")
                        Text("Paste")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.12))
                    .foregroundColor(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
            .padding(10)
            .background(Color.dpTertiaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(viewModel.validationError != nil ? Color.red : Color.secondary.opacity(0.2), lineWidth: 1)
            )

            if let errorMsg = viewModel.validationError {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 12))
                    Text(errorMsg)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(16)
        .background(Color.dpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            // Save URL Button (saves without generating)
            Button(action: { viewModel.saveURL() }) {
                HStack(spacing: 6) {
                    Image(systemName: "bookmark.fill")
                    Text("Save URL")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.dpSecondaryBackground)
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(isWorking)

            // Generate UI Button (starts full pipeline)
            Button(action: { viewModel.generateUI() }) {
                HStack(spacing: 6) {
                    if isWorking {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text(isWorking ? "Generating..." : "Generate UI")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            .disabled(isWorking || viewModel.urlInput.isEmpty)
        }
    }

    @ViewBuilder
    private var statusAndProgressSection: some View {
        switch viewModel.state {
        case .idle:
            engineStatusSnippet
        case .saved:
            savedNoticeSnippet
        case .inProgress(let stage, let progress, let message):
            PipelineProgressView(currentStage: stage, progress: progress, message: message)
        case .readyForReview(let result):
            readyForReviewCard(result: result)
        case .integrating(let progress):
            integratingCard(progress: progress)
        case .completed(let summary):
            completedCard(summary: summary)
        case .failed(let error, let retryStage):
            errorCard(error: error, retryStage: retryStage)
        }
    }

    private var engineStatusSnippet: some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundColor(.secondary)
            if let health = viewModel.engineHealth {
                Text(health.isAlive ? "Engine ready. Paste any Figma URL above to start." : "Demo Mode active. Ready to generate UI preview.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Ready to generate.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 4)
    }

    private var savedNoticeSnippet: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            VStack(alignment: .leading, spacing: 2) {
                Text("URL Saved Successfully")
                    .font(.subheadline.weight(.semibold))
                Text(viewModel.statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func readyForReviewCard(result: GenerationResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("UI Generated Successfully!")
                        .font(.headline)
                    Text("\(result.generatedFiles.count) files ready • \(result.visualDiff.similarityPercentageFormatted) Visual Match")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                StatusBadgeView(
                    title: "Ready",
                    icon: "checkmark.seal.fill",
                    color: .green
                )
            }

            Button(action: { viewModel.isReviewPresented = true }) {
                HStack {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("Review Code & Visual Diff")
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(12)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color.dpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func integratingCard(progress: Double) -> some View {
        HStack(spacing: 12) {
            ProgressView()
            VStack(alignment: .leading, spacing: 2) {
                Text("Integrating Files...")
                    .font(.subheadline.weight(.semibold))
                Text(viewModel.statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.dpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func completedCard(summary: IntegrationSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Integration Complete!")
                        .font(.headline)
                    Text("Added \(summary.addedFiles.count) file(s) into \(summary.targetDirectory)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            HStack {
                Button(action: { viewModel.reset() }) {
                    Text("Generate Another Screen")
                        .font(.subheadline.weight(.medium))
                }
                Spacer()
                Button(action: { viewModel.rollbackLatest() }) {
                    Text("Undo / Rollback")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(16)
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func errorCard(error: DesignPilotError, retryStage: PipelineStage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Generation Failed")
                        .font(.subheadline.weight(.bold))
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.primary)

                    if let suggestion = error.recoverySuggestion {
                        Text("Suggested Fix: \(suggestion)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }

            HStack {
                Spacer()
                Button(action: { viewModel.generateUI() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                        Text("Retry \(retryStage.rawValue)")
                    }
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.15))
                    .foregroundColor(.red)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(14)
        .background(Color.red.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var isWorking: Bool {
        switch viewModel.state {
        case .inProgress, .integrating:
            return true
        default:
            return false
        }
    }

    private func pasteFromClipboard() {
        #if os(iOS)
        if let string = UIPasteboard.general.string {
            viewModel.urlInput = string
        }
        #elseif os(macOS)
        if let string = NSPasteboard.general.string(forType: .string) {
            viewModel.urlInput = string
        }
        #endif
    }
}
