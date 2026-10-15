import Foundation

/// Structured domain errors for DesignPilot SDK and Engine.
public enum DesignPilotError: LocalizedError, Sendable, Codable, Hashable {
    case invalidURL(String)
    case invalidPDF(String)
    case pdfPageNotFound(page: Int, totalPages: Int)
    case missingCredentials(service: String)
    case figmaAccessDenied(reason: String)
    case rateLimited(retryAfterSeconds: Int)
    case unsupportedDesignElements([String])
    case missingAssets([String])
    case projectInspectionFailed(reason: String)
    case aiGenerationFailed(reason: String)
    case compilationFailed(diagnostics: String)
    case visualValidationFailed(similarity: Double, threshold: Double)
    case unsupportedDeploymentTarget(found: String, required: String)
    case engineDaemonOffline(endpoint: String)
    case integrationConflict(conflicts: [String])
    case rollbackFailed(reason: String)
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let msg):
            return "Invalid Figma URL: \(msg)"
        case .invalidPDF(let msg):
            return "Invalid PDF Design File: \(msg)"
        case .pdfPageNotFound(let page, let total):
            return "Requested page \(page) is outside PDF range (total pages: \(total))."
        case .missingCredentials(let service):
            return "Missing credentials for \(service). Please set your Figma Personal Access Token or AI API key."
        case .figmaAccessDenied(let reason):
            return "Figma Access Denied (403): \(reason). Ensure your access token has read permissions for this file."
        case .rateLimited(let secs):
            return "Rate limited by upstream API (429). Please retry in \(secs) seconds."
        case .unsupportedDesignElements(let elements):
            return "Found unsupported design elements: \(elements.joined(separator: ", "))."
        case .missingAssets(let assets):
            return "Missing required visual assets: \(assets.joined(separator: ", "))."
        case .projectInspectionFailed(let reason):
            return "Could not inspect Xcode project: \(reason)"
        case .aiGenerationFailed(let reason):
            return "AI code synthesis failed: \(reason)"
        case .compilationFailed(let diagnostics):
            return "Generated code failed compilation verification: \(diagnostics)"
        case .visualValidationFailed(let sim, let threshold):
            return String(format: "Visual similarity (%.1f%%) did not meet acceptance threshold (%.1f%%).", sim * 100, threshold * 100)
        case .unsupportedDeploymentTarget(let found, let req):
            return "Target iOS version \(found) is below required minimum of \(req)."
        case .engineDaemonOffline(let endpoint):
            return "DesignPilot Engine daemon is not responding at \(endpoint). Run 'designpilot daemon' or switch to standalone demo mode."
        case .integrationConflict(let conflicts):
            return "File conflicts detected in target project: \(conflicts.joined(separator: ", "))."
        case .rollbackFailed(let reason):
            return "Failed to restore backup snapshot: \(reason)"
        case .unknown(let msg):
            return "An unexpected error occurred: \(msg)"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .invalidURL:
            return "Paste a complete Figma URL, such as https://www.figma.com/design/:fileKey/:title?node-id=0:1."
        case .invalidPDF:
            return "Ensure the file exists, is readable, and is a valid PDF export."
        case .pdfPageNotFound:
            return "Select a valid page number within the PDF document."
        case .missingCredentials:
            return "Configure your Figma Personal Access Token in Settings or set FIGMA_ACCESS_TOKEN in your environment."
        case .figmaAccessDenied:
            return "Verify that your Figma account has access to the target file and that the token is valid."
        case .rateLimited(let secs):
            return "Wait \(secs) seconds before making another request."
        case .engineDaemonOffline:
            return "Open Terminal and execute: `designpilot daemon` in your project root, or enable Standalone Preview mode in settings."
        case .integrationConflict:
            return "Review the conflicting files in the diff viewer or choose an alternative destination directory."
        default:
            return "Tap Retry to re-run the failed pipeline step."
        }
    }
}
