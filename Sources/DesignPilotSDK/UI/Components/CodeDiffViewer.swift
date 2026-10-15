import SwiftUI

public struct CodeDiffViewer: View {
    public let code: String
    public let fileName: String
    public let framework: TargetFramework
    @State private var isCopied: Bool = false

    public init(code: String, fileName: String, framework: TargetFramework = .swiftUI) {
        self.code = code
        self.fileName = fileName
        self.framework = framework
    }

    private var lines: [String] {
        code.components(separatedBy: .newlines)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Bar
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "curlybraces.square.fill")
                        .foregroundColor(.blue)
                    Text(fileName)
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                }

                Spacer()

                Button(action: copyToClipboard) {
                    HStack(spacing: 4) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                        Text(isCopied ? "Copied" : "Copy")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.15))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.dpTertiaryBackground)

            Divider()

            // Code Scroll Area
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary.opacity(0.6))
                                .frame(width: 28, alignment: .trailing)

                            Text(line.isEmpty ? " " : line)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(highlightColor(for: line))
                        }
                    }
                }
                .padding(12)
            }
            .background(Color.dpSecondaryBackground.opacity(0.6))
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }

    private func highlightColor(for line: String) -> Color {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("//") {
            return .green.opacity(0.8)
        } else if trimmed.hasPrefix("import ") {
            return .purple
        } else if trimmed.contains("struct ") || trimmed.contains("enum ") || trimmed.contains("func ") {
            return .blue
        } else if trimmed.contains("var body:") {
            return .indigo
        } else if trimmed.contains("@State") || trimmed.contains("@Environment") {
            return .orange
        }
        return .primary
    }

    private func copyToClipboard() {
        #if os(iOS)
        UIPasteboard.general.string = code
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code, forType: .string)
        #endif

        withAnimation {
            isCopied = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                isCopied = false
            }
        }
    }
}
