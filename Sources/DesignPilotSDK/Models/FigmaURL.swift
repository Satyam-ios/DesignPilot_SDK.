import Foundation

/// Represents a parsed and validated Figma design URL.
/// Supports both file URLs (`figma.com/file/...`) and design URLs (`figma.com/design/...`),
/// along with optional node IDs (`?node-id=...`).
public struct FigmaURL: Hashable, Sendable, Codable {
    public let rawString: String
    public let fileKey: String
    public let documentTitle: String?
    public let nodeId: String?

    public init(rawString: String, fileKey: String, documentTitle: String? = nil, nodeId: String? = nil) {
        self.rawString = rawString
        self.fileKey = fileKey
        self.documentTitle = documentTitle
        self.nodeId = nodeId
    }

    /// Normalizes the node ID for the Figma REST API.
    /// URL query params often use dashes (e.g. `123-456`) or encoded colons (`123%3A456`),
    /// whereas the Figma REST API expects a colon (`123:456`).
    public var apiNodeId: String? {
        guard let nodeId = nodeId else { return nil }
        return nodeId.replacingOccurrences(of: "-", with: ":")
    }

    /// Validates and parses a raw URL string into a `FigmaURL`.
    /// - Parameter urlString: The raw URL entered by the user.
    /// - Throws: `FigmaURLError` if the URL format is invalid.
    public static func parse(_ urlString: String) throws -> FigmaURL {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw FigmaURLError.emptyURL
        }

        guard let components = URLComponents(string: trimmed),
              let host = components.host?.lowercased(),
              host.contains("figma.com") else {
            throw FigmaURLError.invalidHost
        }

        // Typical paths:
        // /file/:key/:title
        // /design/:key/:title
        // /proto/:key/:title
        let pathSegments = components.path.split(separator: "/").map(String.init)
        guard pathSegments.count >= 2 else {
            throw FigmaURLError.missingFileKey
        }

        let prefix = pathSegments[0].lowercased()
        guard ["file", "design", "proto"].contains(prefix) else {
            throw FigmaURLError.unsupportedPathType(prefix)
        }

        let fileKey = pathSegments[1]
        guard !fileKey.isEmpty, fileKey.count >= 10 else {
            throw FigmaURLError.invalidFileKey(fileKey)
        }

        let title: String? = pathSegments.count > 2 ? pathSegments[2].removingPercentEncoding : nil

        // Extract node-id from query items if present
        var extractedNodeId: String? = nil
        if let queryItems = components.queryItems {
            if let nodeItem = queryItems.first(where: { $0.name == "node-id" }), let value = nodeItem.value, !value.isEmpty {
                extractedNodeId = value
            }
        }

        return FigmaURL(
            rawString: trimmed,
            fileKey: fileKey,
            documentTitle: title,
            nodeId: extractedNodeId
        )
    }
}

/// Errors occurring during Figma URL validation.
public enum FigmaURLError: LocalizedError, Sendable, Equatable {
    case emptyURL
    case invalidHost
    case missingFileKey
    case invalidFileKey(String)
    case unsupportedPathType(String)

    public var errorDescription: String? {
        switch self {
        case .emptyURL:
            return "Please enter a Figma design URL."
        case .invalidHost:
            return "The URL must be a valid Figma URL (e.g. https://www.figma.com/design/...)."
        case .missingFileKey:
            return "The Figma URL is missing the unique file key segment."
        case .invalidFileKey(let key):
            return "The file key '\(key)' is malformed or invalid."
        case .unsupportedPathType(let type):
            return "Unsupported Figma URL path type: '/\(type)'. Expected '/file' or '/design'."
        }
    }
}
