import SwiftUI

public struct FileTreeListView: View {
    public let files: [GeneratedFile]
    @Binding public var selectedFilePaths: Set<String>
    public let onSelectFile: (GeneratedFile) -> Void

    public init(
        files: [GeneratedFile],
        selectedFilePaths: Binding<Set<String>>,
        onSelectFile: @escaping (GeneratedFile) -> Void
    ) {
        self.files = files
        self._selectedFilePaths = selectedFilePaths
        self.onSelectFile = onSelectFile
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Staged Output Files (\(files.count))")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button(action: toggleSelectAll) {
                    Text(selectedFilePaths.count == files.count ? "Deselect All" : "Select All")
                        .font(.caption)
                }
            }

            VStack(spacing: 6) {
                ForEach(files) { file in
                    HStack(spacing: 10) {
                        Button(action: { toggleSelection(for: file) }) {
                            Image(systemName: selectedFilePaths.contains(file.relativePath) ? "checkmark.square.fill" : "square")
                                .foregroundColor(selectedFilePaths.contains(file.relativePath) ? .blue : .secondary)
                                .font(.system(size: 16))
                        }
                        .buttonStyle(.plain)

                        Image(systemName: iconForFramework(file.framework))
                            .foregroundColor(.blue)
                            .font(.system(size: 14))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(file.fileName)
                                .font(.system(size: 13, weight: .medium))
                            Text(file.relativePath)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        statusBadge(for: file.status)

                        Button(action: { onSelectFile(file) }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(8)
                    .background(Color.dpTertiaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }

    private func toggleSelection(for file: GeneratedFile) {
        if selectedFilePaths.contains(file.relativePath) {
            selectedFilePaths.remove(file.relativePath)
        } else {
            selectedFilePaths.insert(file.relativePath)
        }
    }

    private func toggleSelectAll() {
        if selectedFilePaths.count == files.count {
            selectedFilePaths.removeAll()
        } else {
            selectedFilePaths = Set(files.map(\.relativePath))
        }
    }

    @ViewBuilder
    private func statusBadge(for status: FileChangeStatus) -> some View {
        switch status {
        case .created:
            Text("NEW")
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.green.opacity(0.15))
                .foregroundColor(.green)
                .clipShape(Capsule())
        case .modified:
            Text("MOD")
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.orange.opacity(0.15))
                .foregroundColor(.orange)
                .clipShape(Capsule())
        case .unchanged:
            Text("SAME")
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.gray.opacity(0.15))
                .foregroundColor(.secondary)
                .clipShape(Capsule())
        }
    }

    private func iconForFramework(_ framework: TargetFramework) -> String {
        switch framework {
        case .swiftUI:
            return "swift"
        case .uiKit:
            return "uiwindow.split.2x1"
        case .designTokens:
            return "paintpalette.fill"
        case .assetCatalog:
            return "photo.stack.fill"
        }
    }
}
