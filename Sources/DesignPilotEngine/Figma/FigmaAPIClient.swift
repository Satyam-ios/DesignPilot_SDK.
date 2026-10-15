import Foundation
import DesignPilotSDK

/// Authorized client for communicating with Figma REST APIs.
public struct FigmaAPIClient: Sendable {
    private let accessToken: String?
    private let session: URLSession
    private let baseURL = URL(string: "https://api.figma.com/v1")!

    public init(accessToken: String? = nil, session: URLSession = .shared) {
        // Resolve access token from parameter, environment variable, or return nil
        let resolvedToken = accessToken ?? ProcessInfo.processInfo.environment["FIGMA_ACCESS_TOKEN"]
        self.accessToken = resolvedToken
        self.session = session
    }

    /// Fetches full file document metadata and styles.
    public func fetchFile(fileKey: String) async throws -> FigmaFileResponse {
        let endpoint = baseURL.appendingPathComponent("files/\(fileKey)")
        let data = try await performRequest(url: endpoint)
        return try JSONDecoder().decode(FigmaFileResponse.self, from: data)
    }

    /// Fetches a specific node tree by ID.
    public func fetchNodes(fileKey: String, nodeIds: [String]) async throws -> FigmaNodesResponse {
        var components = URLComponents(url: baseURL.appendingPathComponent("files/\(fileKey)/nodes"), resolvingAgainstBaseURL: true)!
        let joinedIds = nodeIds.joined(separator: ",")
        components.queryItems = [URLQueryItem(name: "ids", value: joinedIds)]

        guard let url = components.url else {
            throw DesignPilotError.invalidURL("Failed to construct Figma nodes request URL.")
        }

        let data = try await performRequest(url: url)
        return try JSONDecoder().decode(FigmaNodesResponse.self, from: data)
    }

    /// Fetches rendered PNG image URL for reference visual diff comparison.
    public func fetchRenderedImageURL(fileKey: String, nodeId: String, scale: Double = 2.0) async throws -> URL {
        var components = URLComponents(url: baseURL.appendingPathComponent("images/\(fileKey)"), resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "ids", value: nodeId),
            URLQueryItem(name: "scale", value: "\(scale)"),
            URLQueryItem(name: "format", value: "png")
        ]

        guard let url = components.url else {
            throw DesignPilotError.invalidURL("Failed to construct Figma image export URL.")
        }

        let data = try await performRequest(url: url)
        struct ImageResponse: Decodable {
            let images: [String: String?]
        }
        let decoded = try JSONDecoder().decode(ImageResponse.self, from: data)
        guard let imageURLString = decoded.images[nodeId] ?? decoded.images.values.first ?? nil,
              let imageURL = URL(string: imageURLString) else {
            throw DesignPilotError.missingAssets(["Rendered reference image for node \(nodeId) not returned by Figma API."])
        }
        return imageURL
    }

    private func performRequest(url: URL) async throws -> Data {
        guard let token = accessToken, !token.isEmpty else {
            throw DesignPilotError.missingCredentials(service: "Figma (FIGMA_ACCESS_TOKEN)")
        }

        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "X-Figma-Token")
        request.timeoutInterval = 30.0

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DesignPilotError.unknown("Invalid HTTP response received.")
        }

        switch httpResponse.statusCode {
        case 200...299:
            return data
        case 401, 403:
            throw DesignPilotError.figmaAccessDenied(reason: "Invalid token or unauthorized file access (HTTP \(httpResponse.statusCode)).")
        case 429:
            let retryAfter = Int(httpResponse.value(forHTTPHeaderField: "Retry-After") ?? "60") ?? 60
            throw DesignPilotError.rateLimited(retryAfterSeconds: retryAfter)
        case 404:
            throw DesignPilotError.figmaAccessDenied(reason: "Figma file or node not found (HTTP 404).")
        default:
            let bodyText = String(data: data, encoding: .utf8) ?? "No details"
            throw DesignPilotError.unknown("Figma API HTTP \(httpResponse.statusCode): \(bodyText)")
        }
    }
}
