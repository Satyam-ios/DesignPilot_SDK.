import Foundation

/// The discrete stages in the Figma-to-Xcode generation pipeline.
public enum PipelineStage: String, Codable, Sendable, CaseIterable, Identifiable {
    case idle = "Idle"
    case validatingURL = "Validating URL & Access"
    case fetchingDesign = "Retrieving Figma Nodes & Tokens"
    case inspectingProject = "Inspecting Xcode Project Target"
    case synthesizingCode = "Synthesizing Adaptive Native Code"
    case visualValidation = "Visual Validation & Diff Analysis"
    case readyForReview = "Awaiting Review & Approval"
    case integrating = "Integrating Files into Project"
    case completed = "Integration Completed"

    public var id: String { rawValue }

    public var stepIndex: Int {
        switch self {
        case .idle: return 0
        case .validatingURL: return 1
        case .fetchingDesign: return 2
        case .inspectingProject: return 3
        case .synthesizingCode: return 4
        case .visualValidation: return 5
        case .readyForReview: return 6
        case .integrating: return 7
        case .completed: return 8
        }
    }

    public var totalSteps: Int { 8 }

    public var descriptionText: String {
        switch self {
        case .idle:
            return "Ready to generate"
        case .validatingURL:
            return "Checking URL format and Figma permissions..."
        case .fetchingDesign:
            return "Parsing AutoLayout tree, styles, and image assets..."
        case .inspectingProject:
            return "Determining Swift target, deployment version, and folder layout..."
        case .synthesizingCode:
            return "Generating responsive SwiftUI source with dynamic type..."
        case .visualValidation:
            return "Rendering simulator frame and calculating visual differences..."
        case .readyForReview:
            return "Generated views and diff report ready for review."
        case .integrating:
            return "Creating rollback backup and writing files to project..."
        case .completed:
            return "Files integrated successfully."
        }
    }
}

/// The state of the DesignPilot system.
public enum GenerationState: Equatable, Sendable {
    case idle
    case saved(FigmaURL)
    case inProgress(stage: PipelineStage, progress: Double, message: String)
    case readyForReview(GenerationResult)
    case integrating(progress: Double)
    case completed(IntegrationSummary)
    case failed(DesignPilotError, retryStage: PipelineStage)

    public static func == (lhs: GenerationState, rhs: GenerationState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.saved(let l), .saved(let r)): return l == r
        case (.inProgress(let s1, let p1, let m1), .inProgress(let s2, let p2, let m2)):
            return s1 == s2 && abs(p1 - p2) < 0.001 && m1 == m2
        case (.readyForReview(let l), .readyForReview(let r)): return l.id == r.id
        case (.integrating(let p1), .integrating(let p2)): return abs(p1 - p2) < 0.001
        case (.completed(let l), .completed(let r)): return l.backupId == r.backupId
        case (.failed(let e1, let s1), .failed(let e2, let s2)):
            return e1.localizedDescription == e2.localizedDescription && s1 == s2
        default: return false
        }
    }
}

/// Result of a successful code generation and visual validation run.
public struct GenerationResult: Identifiable, Codable, Sendable, Hashable {
    public let id: UUID
    public let figmaURL: FigmaURL
    public let generatedFiles: [GeneratedFile]
    public let tokens: DesignTokens
    public let visualDiff: VisualDiffReport
    public let screenName: String
    public let timestamp: Date

    public init(
        id: UUID = UUID(),
        figmaURL: FigmaURL,
        generatedFiles: [GeneratedFile],
        tokens: DesignTokens,
        visualDiff: VisualDiffReport,
        screenName: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.figmaURL = figmaURL
        self.generatedFiles = generatedFiles
        self.tokens = tokens
        self.visualDiff = visualDiff
        self.screenName = screenName
        self.timestamp = timestamp
    }
}

/// Summary of a completed file integration operation.
public struct IntegrationSummary: Codable, Sendable, Hashable {
    public let backupId: String
    public let backupPath: String
    public let addedFiles: [String]
    public let modifiedFiles: [String]
    public let preservedFiles: [String]
    public let targetDirectory: String
    public let timestamp: Date

    public init(
        backupId: String,
        backupPath: String,
        addedFiles: [String],
        modifiedFiles: [String],
        preservedFiles: [String],
        targetDirectory: String,
        timestamp: Date = Date()
    ) {
        self.backupId = backupId
        self.backupPath = backupPath
        self.addedFiles = addedFiles
        self.modifiedFiles = modifiedFiles
        self.preservedFiles = preservedFiles
        self.targetDirectory = targetDirectory
        self.timestamp = timestamp
    }
}
