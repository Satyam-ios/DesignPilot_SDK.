import SwiftUI

/// Full-screen automatic generator loader displayed immediately when the app launches with a configured Figma URL.
public struct AutomaticAppLoaderView: View {
    public let stage: PipelineStage
    public let progress: Double
    public let message: String
    public let uiFramework: UIFramework
    public let discoveredScreensCount: Int

    @State private var isPulsing: Bool = false
    @State private var rotationAngle: Double = 0

    public init(
        stage: PipelineStage,
        progress: Double,
        message: String,
        uiFramework: UIFramework = FigmaAppConfiguration.uiFramework,
        discoveredScreensCount: Int = 9
    ) {
        self.stage = stage
        self.progress = progress
        self.message = message
        self.uiFramework = uiFramework
        self.discoveredScreensCount = discoveredScreensCount
    }

    public var body: some View {
        ZStack {
            Color.dpSystemBackground
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Animated Pulse & App Icon Indicator
                ZStack {
                    // Outer pulsing ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.4), .purple.opacity(0.4), .blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 110, height: 110)
                        .scaleEffect(isPulsing ? 1.15 : 0.95)
                        .rotationEffect(.degrees(rotationAngle))

                    // Core Gradient Glow
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.blue.opacity(0.4), radius: 14, x: 0, y: 6)

                    Image(systemName: "sparkles")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        isPulsing = true
                    }
                    withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }

                // Primary Message Required by Master Specification
                VStack(spacing: 8) {
                    Text("Analyzing your Figma design and generating the native iOS UI/UX. Please wait...")
                        .font(.system(size: 19, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 24)

                    Text("We are creating your app design and screens. Please wait…")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.blue)

                    Text(message.isEmpty ? stage.descriptionText : message)
                        .font(.system(size: 12))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)
                }

                // Progress Bar with Percentage
                VStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.secondary.opacity(0.15))
                                .frame(height: 8)

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(geo.size.width * CGFloat(progress), 12), height: 8)
                                .animation(.spring(response: 0.4), value: progress)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal, 36)

                    HStack {
                        Text("\(Int(progress * 100))% complete")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                        Spacer()
                        Text("Stage \(stageIndex)/14")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 36)
                }

                // Live Architecture Discovery Metrics
                HStack(spacing: 12) {
                    metricTag(icon: "rectangle.stack.fill", title: "Screens", value: "\(discoveredScreensCount)")
                    metricTag(icon: "cpu.fill", title: "Framework", value: uiFramework.rawValue)
                    metricTag(icon: "shield.checkered", title: "Validation", value: "Strict")
                }
                .padding(.horizontal, 24)

                Spacer()

                // Bottom Branding Pill
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 12))
                    Text("Automated Toolchain Compilation & Test Verification")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
            }
        }
    }

    private var stageIndex: Int {
        switch stage {
        case .idle: return 0
        case .validatingURL: return 1
        case .fetchingDesign: return 2
        case .discoveringComponents: return 3
        case .inspectingProject: return 4
        case .planningArchitecture: return 5
        case .synthesizingCode: return 6
        case .integratingNavigation: return 7
        case .buildingApp: return 8
        case .fixingBuildErrors: return 9
        case .runningTests: return 10
        case .visualValidation: return 11
        case .readyForReview: return 12
        case .integrating: return 13
        case .completed: return 14
        }
    }

    private func metricTag(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.dpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
