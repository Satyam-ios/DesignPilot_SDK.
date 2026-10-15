import Foundation

/// HTTP client communicating with the local macOS DesignPilot daemon.
public struct EngineHTTPClient: EngineClientProtocol {
    private let baseURL: URL
    private let session: URLSession
    private let fallbackMockClient: MockEngineClient
    private let executionMode: ExecutionMode

    public init(
        baseURL: URL = DesignPilotConfiguration.defaultDaemonURL,
        executionMode: ExecutionMode = .auto,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.executionMode = executionMode
        self.session = session
        self.fallbackMockClient = MockEngineClient()
    }

    public func checkHealth() async throws -> EngineHealth {
        let healthURL = baseURL.appendingPathComponent("health")
        do {
            var request = URLRequest(url: healthURL)
            request.timeoutInterval = 2.0
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw DesignPilotError.engineDaemonOffline(endpoint: baseURL.absoluteString)
            }
            return try JSONDecoder().decode(EngineHealth.self, from: data)
        } catch {
            if executionMode == .auto || executionMode == .standaloneDemo {
                return try await fallbackMockClient.checkHealth()
            }
            throw DesignPilotError.engineDaemonOffline(endpoint: baseURL.absoluteString)
        }
    }

    public func validateAccess(url: FigmaURL, token: String?) async throws -> Bool {
        if executionMode == .standaloneDemo {
            return try await fallbackMockClient.validateAccess(url: url, token: token)
        }

        let validateURL = baseURL.appendingPathComponent("api/v1/validate-access")
        var request = URLRequest(url: validateURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 5.0

        struct Payload: Encodable {
            let url: FigmaURL
            let token: String?
        }
        request.httpBody = try JSONEncoder().encode(Payload(url: url, token: token))

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw DesignPilotError.engineDaemonOffline(endpoint: baseURL.absoluteString)
            }
            if httpResponse.statusCode == 403 {
                throw DesignPilotError.figmaAccessDenied(reason: "Invalid Figma token or insufficient file read permissions.")
            }
            guard httpResponse.statusCode == 200 else {
                throw DesignPilotError.unknown("Validation failed with HTTP \(httpResponse.statusCode)")
            }
            struct ResponsePayload: Decodable { let valid: Bool }
            let res = try JSONDecoder().decode(ResponsePayload.self, from: data)
            return res.valid
        } catch {
            if executionMode == .auto {
                return try await fallbackMockClient.validateAccess(url: url, token: token)
            }
            throw error
        }
    }

    public func generate(
        request: GenerationRequest,
        onProgress: @Sendable @escaping (PipelineStage, Double, String) -> Void
    ) async throws -> GenerationResult {
        if executionMode == .standaloneDemo {
            return try await fallbackMockClient.generate(request: request, onProgress: onProgress)
        }

        let generateURL = baseURL.appendingPathComponent("api/v1/generate")
        var urlRequest = URLRequest(url: generateURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 120.0
        urlRequest.httpBody = try JSONEncoder().encode(request)

        do {
            onProgress(.validatingURL, 0.1, "Connecting to DesignPilot Engine...")
            let (data, response) = try await session.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw DesignPilotError.engineDaemonOffline(endpoint: baseURL.absoluteString)
            }
            guard httpResponse.statusCode == 200 else {
                if let errorObj = try? JSONDecoder().decode(DesignPilotError.self, from: data) {
                    throw errorObj
                }
                throw DesignPilotError.aiGenerationFailed(reason: "HTTP \(httpResponse.statusCode)")
            }

            let result = try JSONDecoder().decode(GenerationResult.self, from: data)
            onProgress(.completed, 1.0, "Generation complete.")
            return result
        } catch {
            if executionMode == .auto {
                // If daemon is not running locally, seamlessly transition to fallback demo
                return try await fallbackMockClient.generate(request: request, onProgress: onProgress)
            }
            throw error
        }
    }

    public func integrate(request: IntegrationRequest) async throws -> IntegrationSummary {
        if executionMode == .standaloneDemo {
            return try await fallbackMockClient.integrate(request: request)
        }

        let integrateURL = baseURL.appendingPathComponent("api/v1/integrate")
        var urlRequest = URLRequest(url: integrateURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw DesignPilotError.engineDaemonOffline(endpoint: baseURL.absoluteString)
            }
            return try JSONDecoder().decode(IntegrationSummary.self, from: data)
        } catch {
            if executionMode == .auto {
                return try await fallbackMockClient.integrate(request: request)
            }
            throw error
        }
    }

    public func rollback(backupId: String) async throws -> Bool {
        if executionMode == .standaloneDemo {
            return try await fallbackMockClient.rollback(backupId: backupId)
        }

        let rollbackURL = baseURL.appendingPathComponent("api/v1/rollback")
        var urlRequest = URLRequest(url: rollbackURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        struct Payload: Encodable { let backupId: String }
        urlRequest.httpBody = try JSONEncoder().encode(Payload(backupId: backupId))

        let (data, response) = try await session.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            return false
        }
        struct Res: Decodable { let success: Bool }
        let res = try JSONDecoder().decode(Res.self, from: data)
        return res.success
    }
}
