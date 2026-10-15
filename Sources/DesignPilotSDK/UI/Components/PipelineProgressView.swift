import SwiftUI

public struct PipelineProgressView: View {
    public let currentStage: PipelineStage
    public let progress: Double
    public let message: String

    public init(currentStage: PipelineStage, progress: Double, message: String) {
        self.currentStage = currentStage
        self.progress = progress
        self.message = message
    }

    private let displayStages: [PipelineStage] = [
        .validatingURL,
        .fetchingDesign,
        .inspectingProject,
        .synthesizingCode,
        .visualValidation,
        .readyForReview,
        .integrating
    ]

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Generation Pipeline")
                    .font(.headline)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.subheadline.monospacedDigit())
                    .foregroundColor(.secondary)
            }

            // Continuous Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.18))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, min(geo.size.width * CGFloat(progress), geo.size.width)), height: 6)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 6)

            // Step List
            VStack(alignment: .leading, spacing: 10) {
                ForEach(displayStages, id: \.self) { stage in
                    HStack(spacing: 12) {
                        stepIndicator(for: stage)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(stage.rawValue)
                                .font(.system(size: 13, weight: isCurrent(stage) ? .semibold : .regular))
                                .foregroundColor(isCurrent(stage) ? .primary : isCompleted(stage) ? .secondary : .gray)

                            if isCurrent(stage) && !message.isEmpty {
                                Text(message)
                                    .font(.system(size: 11))
                                    .foregroundColor(.blue)
                                    .lineLimit(2)
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .background(Color.dpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    @ViewBuilder
    private func stepIndicator(for stage: PipelineStage) -> some View {
        if isCompleted(stage) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 16))
        } else if isCurrent(stage) {
            ProgressView()
                .scaleEffect(0.7)
                .frame(width: 16, height: 16)
        } else {
            Image(systemName: "circle")
                .foregroundColor(.secondary.opacity(0.4))
                .font(.system(size: 16))
        }
    }

    private func isCompleted(_ stage: PipelineStage) -> Bool {
        return currentStage.stepIndex > stage.stepIndex
    }

    private func isCurrent(_ stage: PipelineStage) -> Bool {
        return currentStage == stage
    }
}
