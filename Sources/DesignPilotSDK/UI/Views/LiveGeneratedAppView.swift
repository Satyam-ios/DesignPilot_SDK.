import SwiftUI

/// All 9 screens discovered and generated from the Figma IoT / Context to Call design flow.
public enum AppScreenDestination: String, CaseIterable, Identifiable {
    case pairing = "1. Pairing"
    case dashboard = "2. Dashboard"
    case contextCall = "3. Context Call"
    case doorRelay = "4. Door Relay"
    case telemetry = "5. Telemetry"
    case security = "6. Security"
    case auditLog = "7. Audit Log"
    case hardware = "8. Hardware"
    case network = "9. Network"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .pairing: return "Gateway Pairing & BLE"
        case .dashboard: return "Smart Panel Dashboard"
        case .contextCall: return "Context to Call VoIP"
        case .doorRelay: return "Door Relay & Access"
        case .telemetry: return "Multi-Sensor Telemetry"
        case .security: return "Perimeter & Panic Siren"
        case .auditLog: return "Event Audit & History"
        case .hardware: return "Hardware & Bus Config"
        case .network: return "Network & Protocol Config"
        }
    }

    public var icon: String {
        switch self {
        case .pairing: return "qrcode.viewfinder"
        case .dashboard: return "square.grid.2x2.fill"
        case .contextCall: return "phone.badge.waveform.fill"
        case .doorRelay: return "lock.shield.fill"
        case .telemetry: return "gauge.with.needle.fill"
        case .security: return "bell.badge.fill"
        case .auditLog: return "clock.arrow.circlepath"
        case .hardware: return "cpu.fill"
        case .network: return "network"
        }
    }
}

/// Live, interactive application container rendering all 9 screens generated from the Figma design.
public struct LiveGeneratedAppView: View {
    public let result: GenerationResult
    public let onBackToGenerator: () -> Void
    public let onInspectArchitecture: () -> Void

    @State private var activeScreen: AppScreenDestination = .dashboard
    @State private var isAudioCallActive: Bool = false
    @State private var isDoorLocked: Bool = true
    @State private var isSirenArmed: Bool = false
    @State private var isVideoStreaming: Bool = true
    @State private var isMuted: Bool = false
    @State private var pinInput: String = ""
    @State private var selectedAuditFilter: String = "All"
    @State private var blePaired: Bool = true
    @State private var liveTemp: Double = 23.4
    @State private var liveHumidity: Double = 46.0

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
        NavigationStack {
            VStack(spacing: 0) {
                // Top Floating Developer HUD Banner
                floatingControlBanner
                    .padding(.top, 6)
                    .padding(.bottom, 6)

                // 9-Screen Flow Navigation Selector
                screenFlowSelector
                    .padding(.bottom, 8)

                Divider()

                // Active Generated Screen
                ScrollView {
                    VStack(spacing: 16) {
                        screenHeaderBanner

                        switch activeScreen {
                        case .pairing:
                            pairingScreenView
                        case .dashboard:
                            dashboardScreenView
                        case .contextCall:
                            contextCallScreenView
                        case .doorRelay:
                            doorRelayScreenView
                        case .telemetry:
                            telemetryScreenView
                        case .security:
                            securityScreenView
                        case .auditLog:
                            auditLogScreenView
                        case .hardware:
                            hardwareScreenView
                        case .network:
                            networkScreenView
                        }
                    }
                    .padding(16)
                }
                .background(Color.dpSystemBackground)
            }
            .navigationTitle(activeScreen.title)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }

    // MARK: - Floating Developer HUD Banner
    private var floatingControlBanner: some View {
        HStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                    .font(.system(size: 11, weight: .bold))
                Text("9 Screens Generated Live")
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
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 16)
    }

    // MARK: - 9-Screen Flow Selector
    private var screenFlowSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AppScreenDestination.allCases) { screen in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            activeScreen = screen
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: screen.icon)
                                .font(.system(size: 11))
                            Text(screen.rawValue)
                                .font(.system(size: 11, weight: activeScreen == screen ? .bold : .medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(activeScreen == screen ? Color.blue : Color.dpSecondaryBackground)
                        .foregroundColor(activeScreen == screen ? .white : .primary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var screenHeaderBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(activeScreen.title)
                    .font(.headline)
                Text("Screen \(activeScreen.rawValue.prefix(1)) of 9 • Generated from Figma Flow V1.3")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
            HStack(spacing: 4) {
                Circle().fill(Color.green).frame(width: 6, height: 6)
                Text("Linked")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.green.opacity(0.12))
            .clipShape(Capsule())
        }
        .padding(12)
        .background(Color.dpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Screen 1: Gateway Pairing
    private var pairingScreenView: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 180)
                VStack(spacing: 12) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 54))
                        .foregroundColor(.blue)
                    Text("Scan Smart Panel QR or Hold Near Device")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Discovered IoT Gateway")
                    .font(.subheadline.weight(.semibold))

                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ContextToCall-Panel-V1.3")
                            .font(.system(size: 13, weight: .bold))
                        Text("MAC: E4:5F:01:9A:2B:11 • RSSI: -42 dBm")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(action: { blePaired.toggle() }) {
                        Text(blePaired ? "Paired" : "Pair")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(blePaired ? Color.green : Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .background(Color.dpSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - Screen 2: Dashboard
    private var dashboardScreenView: some View {
        VStack(spacing: 16) {
            heroDeviceCard
            telemetryMetricsGrid
            quickActionTiles
            navigationShortcutsSection
        }
    }

    // MARK: - Screen 3: Context Call
    private var contextCallScreenView: some View {
        VStack(spacing: 16) {
            // Live Video Stream Viewport
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.85))
                    .frame(height: 220)

                VStack(spacing: 10) {
                    Image(systemName: "person.crop.rectangle.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.6))
                    Text(isAudioCallActive ? "Live FHD Stream • 30 FPS" : "Standby • Tap to Start Call")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if isAudioCallActive {
                    HStack(spacing: 4) {
                        Circle().fill(Color.red).frame(width: 8, height: 8)
                        Text("LIVE 00:42")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Capsule())
                    .padding(12)
                }
            }

            // Call Action Controls
            HStack(spacing: 16) {
                Button(action: { isMuted.toggle() }) {
                    VStack(spacing: 6) {
                        Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.system(size: 20))
                            .foregroundColor(isMuted ? .red : .primary)
                            .frame(width: 50, height: 50)
                            .background(Color.dpSecondaryBackground)
                            .clipShape(Circle())
                        Text(isMuted ? "Unmute" : "Mute")
                            .font(.caption2)
                    }
                }
                .buttonStyle(.plain)

                Button(action: {
                    withAnimation { isAudioCallActive.toggle() }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: isAudioCallActive ? "phone.down.fill" : "phone.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 64, height: 64)
                            .background(isAudioCallActive ? Color.red : Color.green)
                            .clipShape(Circle())
                            .shadow(color: (isAudioCallActive ? Color.red : Color.green).opacity(0.4), radius: 8, x: 0, y: 4)
                        Text(isAudioCallActive ? "End Call" : "Call")
                            .font(.caption.weight(.bold))
                    }
                }
                .buttonStyle(.plain)

                Button(action: { isVideoStreaming.toggle() }) {
                    VStack(spacing: 6) {
                        Image(systemName: isVideoStreaming ? "video.fill" : "video.slash.fill")
                            .font(.system(size: 20))
                            .foregroundColor(isVideoStreaming ? .blue : .secondary)
                            .frame(width: 50, height: 50)
                            .background(Color.dpSecondaryBackground)
                            .clipShape(Circle())
                        Text("Video")
                            .font(.caption2)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Screen 4: Door Relay
    private var doorRelayScreenView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill((isDoorLocked ? Color.green : Color.orange).opacity(0.15))
                        .frame(width: 90, height: 90)
                    Image(systemName: isDoorLocked ? "lock.fill" : "lock.open.fill")
                        .font(.system(size: 40))
                        .foregroundColor(isDoorLocked ? .green : .orange)
                }

                Text(isDoorLocked ? "Door Relay: Locked & Secured" : "Door Relay: Open (Access Granted)")
                    .font(.headline)
                Text(isDoorLocked ? "Tap below or enter 4-digit PIN to unlock" : "Auto-locking in 12 seconds...")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button(action: {
                    withAnimation(.spring(response: 0.35)) {
                        isDoorLocked.toggle()
                    }
                }) {
                    Text(isDoorLocked ? "Unlock Door Relay" : "Engage Lock Relay")
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(isDoorLocked ? Color.blue : Color.orange)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(Color.dpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // PIN Keypad Simulator
            VStack(alignment: .leading, spacing: 10) {
                Text("Security Keypad")
                    .font(.subheadline.weight(.semibold))

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(1...9, id: \.self) { num in
                        Button(action: {
                            if pinInput.count < 4 { pinInput.append("\(num)") }
                        }) {
                            Text("\(num)")
                                .font(.system(size: 18, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.dpTertiaryBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Screen 5: Telemetry
    private var telemetryScreenView: some View {
        VStack(spacing: 12) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                sensorTile(title: "Ambient Temp", value: "\(String(format: "%.1f", liveTemp))°C", icon: "thermometer.medium", accent: .orange)
                sensorTile(title: "Humidity", value: "\(Int(liveHumidity))%", icon: "humidity.fill", accent: .blue)
                sensorTile(title: "Light Intensity", value: "380 Lux", icon: "sun.max.fill", accent: .yellow)
                sensorTile(title: "PIR Motion", value: "Clear", icon: "figure.walk.motion", accent: .green)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Temperature Trend (Last 6 Hours)")
                    .font(.subheadline.weight(.semibold))
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach([21.2, 22.0, 22.8, 23.1, 23.5, 23.4], id: \.self) { val in
                        VStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(height: CGFloat((val - 20) * 20))
                            Text("\(Int(val))°")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 100)
                .padding(12)
                .background(Color.dpSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func sensorTile(title: String, value: String, icon: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(accent)
                Spacer()
            }
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3.weight(.bold))
        }
        .padding(12)
        .background(Color.dpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Screen 6: Security Alerts
    private var securityScreenView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Image(systemName: isSirenArmed ? "bell.badge.fill" : "bell.slash.fill")
                    .font(.system(size: 44))
                    .foregroundColor(isSirenArmed ? .red : .secondary)

                Text(isSirenArmed ? "Security Perimeter: Armed" : "Perimeter: Disarmed")
                    .font(.headline)

                Toggle("Arm Perimeter Sensors", isOn: $isSirenArmed)
                    .padding(.horizontal, 8)

                Button(action: {}) {
                    HStack {
                        Image(systemName: "exclamationmark.octagon.fill")
                        Text("Trigger 110dB Panic Siren")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(Color.dpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Screen 7: Event Audit Log
    private var auditLogScreenView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Filter", selection: $selectedAuditFilter) {
                Text("All").tag("All")
                Text("Calls").tag("Calls")
                Text("Access").tag("Access")
            }
            .pickerStyle(.segmented)

            VStack(spacing: 8) {
                auditRow(icon: "phone.fill", title: "Context to Call connected", time: "10 mins ago", color: .blue)
                auditRow(icon: "lock.open.fill", title: "Door Relay unlocked via Passkey", time: "28 mins ago", color: .green)
                auditRow(icon: "bell.badge.fill", title: "Motion detected at panel front", time: "1 hour ago", color: .orange)
                auditRow(icon: "wifi", title: "Gateway re-connected to Wi-Fi", time: "3 hours ago", color: .purple)
                auditRow(icon: "power", title: "Smart Panel cold booted", time: "Yesterday", color: .gray)
            }
        }
    }

    private func auditRow(icon: String, title: String, time: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 32, height: 32)
                .overlay(Image(systemName: icon).font(.system(size: 13)).foregroundColor(color))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                Text(time)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(10)
        .background(Color.dpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Screen 8: Hardware Config
    private var hardwareScreenView: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Hardware Diagnostics")
                    .font(.subheadline.weight(.semibold))

                hardwareInfoRow(label: "Gateway Model", value: "ContextToCall IoT Panel V1.3")
                hardwareInfoRow(label: "Firmware Version", value: "v2.4.1-build88 (Stable)")
                hardwareInfoRow(label: "Relay 1 Bus", value: "12V DC Normal Open")
                hardwareInfoRow(label: "Audio Codec", value: "Opus 48kHz Stereo")
                hardwareInfoRow(label: "CPU Load", value: "8.2% @ 1.2 GHz")
            }
            .padding(14)
            .background(Color.dpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button(action: {}) {
                Text("Reboot Smart Panel Gateway")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
        }
    }

    private func hardwareInfoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .semibold))
        }
    }

    // MARK: - Screen 9: Network Protocols
    private var networkScreenView: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Network & Cloud Configuration")
                    .font(.subheadline.weight(.semibold))

                hardwareInfoRow(label: "IP Address", value: "192.168.1.144 (DHCP)")
                hardwareInfoRow(label: "MQTT Broker", value: "tls://iot.vgroup.com:8883")
                hardwareInfoRow(label: "WebRTC Gateway", value: "p2p.coturn.relay:3478")
                hardwareInfoRow(label: "Push Notifications", value: "APNs Active")

                Divider()

                Toggle("Enable Cloud P2P Tunnel", isOn: .constant(true))
                Toggle("Auto-Sync Audit Logs", isOn: .constant(true))
            }
            .padding(14)
            .background(Color.dpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
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
                    Text("-58 dBm")
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
                    subtitle: isDoorLocked ? "Locked & Secured" : "Unlocked (Open)",
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
                    subtitle: isSirenArmed ? "Armed" : "Disarmed",
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
        VStack(spacing: 12) {
            Button(action: {
                withAnimation(.spring(response: 0.35)) {
                    isAudioCallActive.toggle()
                    activeScreen = .contextCall
                }
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
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

                    Image(systemName: "chevron.right")
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

    // MARK: - Navigation Shortcuts
    private var navigationShortcutsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Switch to Other Generated Screens")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)

            VStack(spacing: 1) {
                screenShortcutRow(screen: .contextCall, subtitle: "2-Way VoIP stream & video call viewport")
                Divider()
                screenShortcutRow(screen: .doorRelay, subtitle: "Remote door unlock, keypad & relay status")
                Divider()
                screenShortcutRow(screen: .telemetry, subtitle: "Live charts for Temp, Lux, Humidity, PIR")
                Divider()
                screenShortcutRow(screen: .security, subtitle: "110dB Siren trigger & perimeter arming")
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func screenShortcutRow(screen: AppScreenDestination, subtitle: String) -> some View {
        Button(action: {
            withAnimation { activeScreen = screen }
        }) {
            HStack {
                Image(systemName: screen.icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text(screen.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                    Text(subtitle)
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
        .buttonStyle(.plain)
    }
}
