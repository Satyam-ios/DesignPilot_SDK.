import SwiftUI

/// Live, interactive application container rendered immediately when DesignPilot finishes generating the design.
public struct LiveGeneratedAppView: View {
    public let result: GenerationResult
    public let onBackToGenerator: () -> Void
    public let onInspectArchitecture: () -> Void

    @State private var navigationPath = NavigationPath()
    @State private var isAudioCallActive: Bool = false
    @State private var isDoorLocked: Bool = true
    @State private var isSirenArmed: Bool = false
    @State private var isVideoStreaming: Bool = true
    @State private var callDurationSeconds: Int = 0
    @State private var timerActive: Bool = false
    @State private var selectedTab: Int = 0

    public init(
        result: GenerationResult,
        onBackToGenerator: @escaping () -> Void,
        onInspectArchitecture: @escaping () -> Void
    ) {
        self.result = result
        self.onBackToGenerator = onBackToGenerator
        self.onInspectArchitecture = onInspectArchitecture
    }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .top) {
                // Main Application Flow
                ScrollView {
                    VStack(spacing: 16) {
                        // Spacing for top floating toolbar
                        Color.clear.frame(height: 52)

                        heroDeviceCard
                        telemetryMetricsGrid
                        quickActionTiles
                        callToActionSection
                        navigationShortcutsSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
                .background(Color.dpSystemBackground)

                // Floating Developer HUD Banner
                floatingControlBanner
            }
            .navigationTitle(result.screenName)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationDestination(for: String.self) { destination in
                if destination == "details" {
                    detailScreenView
                } else if destination == "settings" {
                    settingsScreenView
                }
            }
        }
    }

    // MARK: - Floating Developer HUD Banner
    private var floatingControlBanner: some View {
        HStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                    .font(.system(size: 11, weight: .bold))
                Text("Live Generated App")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue)
            .clipShape(Capsule())

            Spacer()

            Button(action: onInspectArchitecture) {
                HStack(spacing: 4) {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("Architecture & Code")
                }
                .font(.system(size: 11, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.secondary.opacity(0.18))
                .foregroundColor(.primary)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Button(action: onBackToGenerator) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 11, weight: .semibold))
                    .padding(6)
                    .background(Color.secondary.opacity(0.18))
                    .foregroundColor(.primary)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 3)
        .padding(.horizontal, 14)
        .padding(.top, 4)
    }

    // MARK: - Hero Device Card
    private var heroDeviceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Context to Call IoT Panel")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                    Text("Main Gateway • Panel V1.3")
                        .font(.title3.weight(.bold))
                }
                Spacer()
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Online")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.12))
                .clipShape(Capsule())
            }

            Divider()

            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Image(systemName: "battery.100.bolt")
                        .foregroundColor(.green)
                    Text("98% Charged")
                        .font(.caption.weight(.medium))
                }
                HStack(spacing: 6) {
                    Image(systemName: "wifi")
                        .foregroundColor(.blue)
                    Text("-58 dBm (Strong)")
                        .font(.caption.weight(.medium))
                }
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "shield.checkered")
                        .foregroundColor(.purple)
                    Text("Encrypted")
                        .font(.caption.weight(.medium))
                }
            }
            .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.dpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Telemetry Metrics Grid
    private var telemetryMetricsGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Panel Telemetry & Status")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                metricCard(
                    title: "Door Relay",
                    subtitle: isDoorLocked ? "Locked & Secured" : "Unlocked (Access Granted)",
                    icon: isDoorLocked ? "lock.fill" : "lock.open.fill",
                    accent: isDoorLocked ? .green : .orange,
                    badgeText: "Tap to Toggle"
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        isDoorLocked.toggle()
                    }
                }

                metricCard(
                    title: "Video Stream",
                    subtitle: isVideoStreaming ? "1080p FHD Active" : "Stream Standby",
                    icon: "video.fill",
                    accent: isVideoStreaming ? .blue : .gray,
                    badgeText: isVideoStreaming ? "Live" : "Idle"
                ) {
                    withAnimation {
                        isVideoStreaming.toggle()
                    }
                }

                metricCard(
                    title: "Alert Siren",
                    subtitle: isSirenArmed ? "Armed (Monitoring)" : "Disarmed",
                    icon: "bell.badge.fill",
                    accent: isSirenArmed ? .red : .secondary,
                    badgeText: isSirenArmed ? "Armed" : "Off"
                ) {
                    withAnimation {
                        isSirenArmed.toggle()
                    }
                }

                metricCard(
                    title: "Network Latency",
                    subtitle: "14ms • P2P Tunnel",
                    icon: "network",
                    accent: .purple,
                    badgeText: "Optimal"
                ) {}
            }
        }
    }

    private func metricCard(
        title: String,
        subtitle: String,
        icon: String,
        accent: Color,
        badgeText: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(accent.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(accent)
                    }
                    Spacer()
                    Text(badgeText)
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(accent.opacity(0.12))
                        .foregroundColor(accent)
                        .clipShape(Capsule())
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(12)
            .background(Color.dpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Quick Action Tiles
    private var quickActionTiles: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Interactive Controls")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                // Context Call Button with active states
                Button(action: {
                    withAnimation(.spring(response: 0.35)) {
                        isAudioCallActive.toggle()
                    }
                }) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(isAudioCallActive ? Color.white.opacity(0.2) : Color.white.opacity(0.2))
                                .frame(width: 38, height: 38)
                            Image(systemName: isAudioCallActive ? "phone.down.fill" : "phone.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(isAudioCallActive ? "Connected: Context to Call" : "Start Context to Call")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Text(isAudioCallActive ? "00:42 • 2-Way Audio Streaming" : "Initiate VoIP audio session with smart panel")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.85))
                        }

                        Spacer()

                        Image(systemName: isAudioCallActive ? "waveform" : "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(14)
                    .background(
                        LinearGradient(
                            colors: isAudioCallActive ? [.red, .orange] : [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: (isAudioCallActive ? Color.red : Color.blue).opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Call to Action Section
    private var callToActionSection: some View {
        HStack(spacing: 12) {
            Button(action: {
                withAnimation {
                    isDoorLocked = false
                }
            }) {
                HStack {
                    Image(systemName: "key.fill")
                    Text("Unlock Door")
                        .font(.system(size: 13, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.dpSecondaryBackground)
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)

            Button(action: {
                withAnimation {
                    isVideoStreaming.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "camera.viewfinder")
                    Text("Snapshot")
                        .font(.system(size: 13, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.dpSecondaryBackground)
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Navigation Shortcuts
    private var navigationShortcutsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Connected Screen Flows")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)

            VStack(spacing: 1) {
                NavigationLink(value: "details") {
                    HStack {
                        Image(systemName: "chart.xyaxis.line")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Full Telemetry & History Log")
                                .font(.system(size: 13, weight: .medium))
                            Text("Real-time sensor graphs, event audit, diagnostics")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(Color.dpSecondaryBackground)
                }

                Divider()

                NavigationLink(value: "settings") {
                    HStack {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("IoT Panel Settings & Protocols")
                                .font(.system(size: 13, weight: .medium))
                            Text("Configure MQTT/WebSockets, credentials, triggers")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(Color.dpSecondaryBackground)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: - Subscreen: Detail Screen
    private var detailScreenView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Device Telemetry & Audit Log")
                    .font(.title2.weight(.bold))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Events")
                        .font(.headline)

                    ForEach(["Audio Call Started (VoIP)", "Motion Detected (PIR Sensor)", "Door Relay Disengaged", "System Heartbeat OK"], id: \.self) { event in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(event)
                                .font(.system(size: 13))
                            Spacer()
                            Text("Just now")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(10)
                        .background(Color.dpSecondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("Telemetry Details")
        .background(Color.dpSystemBackground)
    }

    // MARK: - Subscreen: Settings Screen
    private var settingsScreenView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Hardware & Protocol Configuration")
                    .font(.title2.weight(.bold))

                VStack(spacing: 12) {
                    Toggle("Enable Remote P2P Streaming", isOn: .constant(true))
                    Toggle("Push Notifications for Alerts", isOn: .constant(true))
                    Toggle("Biometric Relay Authentication", isOn: .constant(false))
                }
                .padding(16)
                .background(Color.dpSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(16)
        }
        .navigationTitle("Panel Settings")
        .background(Color.dpSystemBackground)
    }
}
