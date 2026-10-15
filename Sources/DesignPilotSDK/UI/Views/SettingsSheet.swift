import SwiftUI

public struct SettingsSheet: View {
    @ObservedObject public var viewModel: DesignPilotViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var daemonURLString: String
    @State private var tokenString: String
    @State private var targetDir: String
    @State private var threshold: Double

    public init(viewModel: DesignPilotViewModel) {
        self.viewModel = viewModel
        _daemonURLString = State(initialValue: viewModel.configuration.daemonURL.absoluteString)
        _tokenString = State(initialValue: viewModel.configuration.figmaAccessToken ?? "")
        _targetDir = State(initialValue: viewModel.configuration.defaultTargetDirectory)
        _threshold = State(initialValue: viewModel.configuration.visualThreshold)
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Engine Connection")) {
                    HStack {
                        Text("Daemon URL")
                        Spacer()
                        TextField("http://127.0.0.1:8088", text: $daemonURLString)
                            .multilineTextAlignment(.trailing)
                            .autocorrectionDisabled()
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            #endif
                    }

                    HStack {
                        Text("Engine Status")
                        Spacer()
                        if let health = viewModel.engineHealth {
                            StatusBadgeView(
                                title: health.isAlive ? "Online (v\(health.version))" : "Offline",
                                icon: health.isAlive ? "bolt.fill" : "bolt.slash.fill",
                                color: health.isAlive ? .green : .secondary
                            )
                        } else {
                            Text("Checking...")
                                .foregroundColor(.secondary)
                        }
                    }

                    Button("Test Connection") {
                        Task { await viewModel.refreshEngineHealth() }
                    }
                }

                Section(header: Text("Figma Access Credentials")) {
                    SecureField("Personal Access Token (figd_...)", text: $tokenString)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .autocorrectionDisabled()

                    Text("Token is stored securely in local device memory or Keychain. It is never transmitted to third parties.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Code Generation Settings")) {
                    HStack {
                        Text("Target Directory")
                        Spacer()
                        TextField("Views/Generated", text: $targetDir)
                            .multilineTextAlignment(.trailing)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Visual Match Acceptance")
                            Spacer()
                            Text("\(Int(threshold * 100))%")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $threshold, in: 0.85...1.0, step: 0.01)
                    }
                }

                Section(header: Text("Rollback & Safety")) {
                    if let summary = viewModel.lastIntegrationSummary {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Latest Backup Snapshot:")
                                .font(.caption.weight(.semibold))
                            Text(summary.backupId)
                                .font(.caption.monospaced())
                                .foregroundColor(.secondary)
                        }

                        Button(role: .destructive, action: {
                            viewModel.rollbackLatest()
                            dismiss()
                        }) {
                            Label("Roll Back Last Integration", systemImage: "arrow.uturn.backward")
                        }
                    } else {
                        Text("No active integration backups on record.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("SDK Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
