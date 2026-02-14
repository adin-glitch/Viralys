import Foundation

// MARK: - API Configuration
/// Holds Claude API configuration constants
enum APIConfig {
    /// Replace with your Claude API key for development
    static let claudeAPIKey = "YOUR_API_KEY_HERE"

    /// Claude API endpoint
    static let baseURL = "https://api.anthropic.com/v1/messages"

    /// Model to use
    static let model = "claude-sonnet-4-20250514"

    /// Max tokens for response
    static let maxTokens = 2048

    /// API version header
    static let apiVersion = "2023-06-01"

    /// UserDefaults key for user-provided API key
    static let apiKeyUserDefaultsKey = "claudeAPIKey"

    /// Returns the active API key (UserDefaults override or hardcoded fallback)
    static var activeAPIKey: String {
        let userKey = UserDefaults.standard.string(forKey: apiKeyUserDefaultsKey) ?? ""
        return userKey.isEmpty ? claudeAPIKey : userKey
    }

    /// Whether a valid API key is configured
    static var hasValidKey: Bool {
        let key = activeAPIKey
        return !key.isEmpty && key != "YOUR_API_KEY_HERE"
    }
}
