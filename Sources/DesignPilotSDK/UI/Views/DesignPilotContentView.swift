import SwiftUI
import UniformTypeIdentifiers

/// Main container view rendering the DesignPilot developer interface supporting both Figma URLs and PDF designs.
public struct DesignPilotContentView: View {
    @ObservedObject public var viewModel: DesignPilotViewModel

    public init(viewModel: DesignPilotViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            if case .readyForReview(let result) = viewModel.state {
                LiveGeneratedAppView(
                    result: result,
                    onBackToGenerator: { viewModel.reset() },
                    onInspectArchitecture: { viewModel.isReviewPresented = true }
                )
            } else if case .completed = viewModel.state, let result = viewModel.lastResult {
                LiveGeneratedAppView(
                    result: result,
                    onBackToGenerator: { viewModel.reset() },
                    onInspectArchitecture: { viewModel.isReviewPresented = true }
                )
            } else if case .inProgress(let stage, let progress, let message) = viewModel.state {
                AutomaticAppLoaderView(
                    stage: stage,
                    progress: progress,
                    message: message,
                    uiFramework: FigmaAppConfiguration.uiFramework,
                    discoveredScreensCount: 9
                )
            } else {
                generatorFormView
            }
        }
        .fileImporter(
            isPresented: $viewModel.isFileImporterPresented,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    viewModel.handleFileImportResult(.success(url))
                }
            case .failure(let error):
                viewModel.handleFileImportResult(.failure(error))
            }
        }
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

    private var generatorFormView: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerBar
                designSourceInputCard
                actionButtonsSection
                statusAndProgressSection
            }
            .padding(16)
        }
        .background(Color.dpSystemBackground)
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
                Text("AI-Powered Figma & PDF to Xcode UI Generator")
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

    private var designSourceInputCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Segmented Mode Switcher: Figma URL vs PDF Upload
            Picker("Source Mode", selection: $viewModel.inputMode) {
                ForEach(DesignInputMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            if viewModel.inputMode == .figmaURL {
                figmaURLInputSection
            } else {
                pdfUploadInputSection
            }

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

    private var figmaURLInputSection: some View {
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
                        Text("Saved (\(String(saved.fileKey.prefix(6)))...)")
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
        }
    }

    private var pdfUploadInputSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Design PDF Document")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if let info = viewModel.selectedPDFInfo {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 11))
                        Text("Loaded (\(info.pageCount) pgs)")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                }
            }

            if let info = viewModel.selectedPDFInfo {
                // PDF Document Details Card
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.15))
                            .frame(width: 40, height: 44)
                        Image(systemName: "doc.richtext.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(info.fileName)
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)
                        HStack(spacing: 6) {
                            Text("\(info.pageCount) Page(s)")
                            Text("•")
                            Text(info.formattedFileSize)
                        }
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: {
                        viewModel.selectedPDFInfo = nil
                        viewModel.pdfFilePathInput = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(10)
                .background(Color.dpTertiaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                // Page Selector if multi-page
                if info.pageCount > 1 {
                    HStack {
                        Text("Target Screen Page:")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Picker("Page", selection: Binding(
                            get: { info.selectedPage },
                            set: { viewModel.selectPDFPage($0) }
                        )) {
                            ForEach(1...info.pageCount, id: \.self) { p in
                                Text("Page \(p)").tag(p)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
            } else {
                // Browse Button & File Path Field
                VStack(spacing: 8) {
                    Button(action: { viewModel.isFileImporterPresented = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.badge.plus")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Upload / Browse Design PDF...")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        )
                    }
                    .buttonStyle(.plain)

                    HStack(spacing: 8) {
                        Image(systemName: "folder")
                            .foregroundColor(.secondary)
                            .font(.system(size: 13))

                        TextField("Or enter local file path (/path/to/flow.pdf)", text: $viewModel.pdfFilePathInput)
                            .font(.system(size: 12, design: .monospaced))
                            .autocorrectionDisabled()
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
                            #endif

                        if !viewModel.pdfFilePathInput.isEmpty {
                            Button(action: { viewModel.savePDFSource() }) {
                                Text("Load")
                                    .font(.caption.weight(.bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.15))
                                    .foregroundColor(.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(8)
                    .background(Color.dpTertiaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }

    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            // Save Source Button
            Button(action: {
                if viewModel.inputMode == .figmaURL {
                    viewModel.saveURL()
                } else {
                    viewModel.savePDFSource()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "bookmark.fill")
                    Text(viewModel.inputMode == .figmaURL ? "Save URL" : "Save PDF")
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

            // Generate UI Button
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
            .disabled(isWorking || isGenerateDisabled)
        }
    }

    private var isGenerateDisabled: Bool {
        if viewModel.inputMode == .figmaURL {
            return viewModel.urlInput.isEmpty
        } else {
            return viewModel.selectedPDFInfo == nil && viewModel.pdfFilePathInput.isEmpty
        }
    }

    @ViewBuilder
    private var statusAndProgressSection: some View {
        switch viewModel.state {
        case .idle:
            engineStatusSnippet
        case .saved, .savedSource:
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
                Text(health.isAlive ? "Engine ready. Paste Figma URL or upload PDF above to start." : "Demo Mode active. Ready to generate UI preview.")
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
                Text("Design Source Saved Successfully")
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
