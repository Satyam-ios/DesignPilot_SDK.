import SwiftUI

public struct VisualComparisonView: View {
    public let report: VisualDiffReport
    @State private var comparisonMode: Int = 0 // 0: Side-by-side, 1: Discrepancies
    @State private var splitRatio: CGFloat = 0.5

    public init(report: VisualDiffReport) {
        self.report = report
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header stats
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Visual Accuracy Validation")
                        .font(.headline)
                    Text("Tested against \(report.testedDevices.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 8) {
                    StatusBadgeView(
                        title: report.similarityPercentageFormatted,
                        icon: report.passedThreshold ? "checkmark.seal.fill" : "exclamationmark.triangle.fill",
                        color: report.passedThreshold ? .green : .orange
                    )

                    StatusBadgeView(
                        title: "Iteration \(report.iterationCount)",
                        icon: "arrow.triangle.2.circlepath",
                        color: .blue
                    )
                }
            }

            Picker("Mode", selection: $comparisonMode) {
                Text("Visual Diff").tag(0)
                Text("Discrepancies (\(report.discrepancies.count))").tag(1)
            }
            .pickerStyle(.segmented)

            if comparisonMode == 0 {
                visualComparisonPane
            } else {
                discrepancyListPane
            }
        }
        .padding(16)
        .background(Color.dpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var visualComparisonPane: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Left: Figma Reference Canvas Mockup
                VStack(spacing: 6) {
                    HStack {
                        Image(systemName: "f.cursive.circle.fill")
                            .foregroundColor(.purple)
                        Text("Figma Reference")
                            .font(.caption.weight(.semibold))
                    }
                    mockCanvas(title: "Reference Frame", accent: .purple)
                }

                // Right: Generated SwiftUI Simulator Snapshot
                VStack(spacing: 6) {
                    HStack {
                        Image(systemName: "apple.logo")
                            .foregroundColor(.blue)
                        Text("Xcode Simulator")
                            .font(.caption.weight(.semibold))
                    }
                    mockCanvas(title: "Simulator Snapshot", accent: .blue)
                }
            }

            HStack {
                Text("Acceptance Threshold: \(Int(report.acceptanceThreshold * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(report.passedThreshold ? "Status: Passed Validation" : "Status: Needs Refinement")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(report.passedThreshold ? .green : .orange)
            }
        }
    }

    private func mockCanvas(title: String, accent: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.dpTertiaryBackground)
                .frame(height: 180)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(accent.opacity(0.3), lineWidth: 1)
                )

            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(accent.opacity(0.15))
                    .frame(width: 80, height: 14)
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.12))
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .padding(.horizontal, 16)
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(accent.opacity(0.2))
                        .frame(height: 36)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(accent.opacity(0.2))
                        .frame(height: 36)
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private var discrepancyListPane: some View {
        VStack(alignment: .leading, spacing: 10) {
            if report.discrepancies.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Zero layout or styling discrepancies detected!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 12)
            } else {
                ForEach(report.discrepancies) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.type.rawValue)
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.15))
                                .foregroundColor(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 4))

                            Text(item.elementName)
                                .font(.system(size: 12, weight: .semibold))

                            Spacer()

                            Text(item.severity.rawValue)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(item.severity == .high ? .red : .secondary)
                        }

                        HStack(spacing: 8) {
                            Text("Expected: \(item.expected)")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text("•")
                                .foregroundColor(.secondary)
                            Text("Actual: \(item.actual)")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }

                        Text("Fix: \(item.suggestedFix)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .padding(10)
                    .background(Color.dpTertiaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}
