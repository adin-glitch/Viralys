import Foundation

// MARK: - API Client
/// URLSession-based HTTP client for Claude API communication
enum APIClient {

    // MARK: - Errors

    enum APIError: LocalizedError {
        case noAPIKey
        case invalidURL
        case networkError(Error)
        case rateLimited
        case invalidResponse
        case serverError(Int, String)
        case decodingError(String)

        var errorDescription: String? {
            switch self {
            case .noAPIKey:
                return "No API key configured. Add your Claude API key in Settings."
            case .invalidURL:
                return "Invalid API URL."
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .rateLimited:
                return "Rate limited. Please wait a moment and try again."
            case .invalidResponse:
                return "Invalid response from server."
            case .serverError(let code, let message):
                return "Server error (\(code)): \(message)"
            case .decodingError(let message):
                return "Failed to parse response: \(message)"
            }
        }
    }

    // MARK: - Response Models

    private struct ClaudeResponse: Codable {
        let content: [ContentBlock]

        struct ContentBlock: Codable {
            let type: String
            let text: String?
        }
    }

    private struct ClaudeErrorResponse: Codable {
        let error: ErrorDetail

        struct ErrorDetail: Codable {
            let message: String
        }
    }

    // MARK: - Send Message

    /// Sends a message to the Claude API and returns the text response
    static func sendMessage(systemPrompt: String, userMessage: String) async throws -> String {
        guard APIConfig.hasValidKey else {
            throw APIError.noAPIKey
        }

        guard let url = URL(string: APIConfig.baseURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(APIConfig.activeAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue(APIConfig.apiVersion, forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = 60

        let body: [String: Any] = [
            "model": APIConfig.model,
            "max_tokens": APIConfig.maxTokens,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": userMessage]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            break
        case 429:
            throw APIError.rateLimited
        default:
            let errorMessage: String
            if let errorResponse = try? JSONDecoder().decode(ClaudeErrorResponse.self, from: data) {
                errorMessage = errorResponse.error.message
            } else {
                errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            }
            throw APIError.serverError(httpResponse.statusCode, errorMessage)
        }

        let claudeResponse = try JSONDecoder().decode(ClaudeResponse.self, from: data)

        guard let textContent = claudeResponse.content.first(where: { $0.type == "text" }),
              let text = textContent.text else {
            throw APIError.invalidResponse
        }

        return text
    }
}
