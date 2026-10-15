import SwiftUI

public struct ReviewIntegrationSheet: View {
    public let result: GenerationResult
    public let onIntegrate: (Set<String>) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var selectedFilePaths: Set<String>
    @State private var activeFile: GeneratedFile?
    @State private var activeTab: Int = 0 // 0: Files & Code, 1: Visual Comparison, 2: Tokens

    public init(result: GenerationResult, onIntegrate: @escaping (Set<String>) -> Void) {
        self.result = result
        self.onIntegrate = onIntegrate
        _selectedFilePaths = State(initialValue: Set(result.generatedFiles.map(\.relativePath)))
        _activeFile = State(initialValue: result.generatedFiles.first)
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Tab", selection: $activeTab) {
                    Text("Code & Files").tag(0)
                    Text("Visual Accuracy").tag(1)
                    Text("Design Tokens").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if activeTab == 0 {
                            codeTabContent
                        } else if activeTab == 1 {
                            VisualComparisonView(report: result.visualDiff)
                        } else {
                            tokensTabContent
                        }

                        safetyNoticeBox
                    }
                    .padding(16)
                }

                Divider()

                bottomActionBar
            }
            .navigationTitle("Review Generated UI")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var codeTabContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            FileTreeListView(
                files: result.generatedFiles,
                selectedFilePaths: $selectedFilePaths,
                onSelectFile: { file in activeFile = file }
            )

            if let file = activeFile {
                CodeDiffViewer(code: file.content, fileName: file.fileName, framework: file.framework)
            }
        }
    }

    private var tokensTabContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Extracted Design Tokens")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Color Palette (\(result.tokens.colors.count))")
                    .font(.subheadline.weight(.semibold))

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 8) {
                    ForEach(result.tokens.colors) { token in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color(red: token.red, green: token.green, blue: token.blue))
                                .frame(width: 22, height: 22)
                                .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 1))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(token.name)
                                    .font(.system(size: 11, weight: .medium))
                                Text(token.hex)
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(8)
                        .background(Color.dpSecondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Typography Styles (\(result.tokens.typography.count))")
                    .font(.subheadline.weight(.semibold))

                ForEach(result.tokens.typography) { typo in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(typo.name)
                                .font(.system(size: 12, weight: .semibold))
                            Text("\(typo.fontFamily) • \(Int(typo.fontSize))pt • \(typo.fontWeight)")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(8)
                    .background(Color.dpSecondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(14)
        .background(Color.dpTertiaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var safetyNoticeBox: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "shield.lefthalf.filled")
                .foregroundColor(.blue)
                .font(.system(size: 16))

            VStack(alignment: .leading, spacing: 2) {
                Text("Non-Destructive Staging Guarantee")
                    .font(.system(size: 12, weight: .semibold))
                Text("Integration generates an atomic rollback snapshot before writing any file. Existing unrelated files are untouched.")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color.blue.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var bottomActionBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(selectedFilePaths.count) of \(result.generatedFiles.count) files selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                onIntegrate(selectedFilePaths)
                dismiss()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.doc.fill")
                    Text("Integrate into Project")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(selectedFilePaths.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(selectedFilePaths.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.dpSecondaryBackground)
    }
}
