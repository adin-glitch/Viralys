import Foundation

// MARK: - Text Post Analyzer
/// Builds platform-specific prompts, calls Claude API, and parses results
enum TextPostAnalyzer {

    // MARK: - Analyze

    /// Analyzes a text post for the given platform and returns a TextAnalysisResult
    static func analyze(text: String, platform: SocialPlatform) async throws -> TextAnalysisResult {
        let systemPrompt = buildSystemPrompt(for: platform)
        let userMessage = buildUserMessage(text: text, platform: platform)

        let response = try await APIClient.sendMessage(
            systemPrompt: systemPrompt,
            userMessage: userMessage
        )

        return try parseResponse(response, originalText: text, platform: platform)
    }

    // MARK: - Prompt Building

    private static func buildSystemPrompt(for platform: SocialPlatform) -> String {
        let platformCriteria: String
        switch platform {
        case .twitter:
            platformCriteria = """
            Twitter/X Optimization Criteria:
            - Brevity is king: every word must earn its place (280 char limit)
            - Hot takes and contrarian opinions drive engagement
            - Strong CTAs: "RT if you agree", questions, polls
            - Thread hooks: "A thread:" or numbered lists tease more content
            - Use line breaks for visual separation
            - Punchy, conversational tone
            - Avoid hashtag spam (0-2 max)
            - Emojis used sparingly for emphasis, not decoration
            """
        case .linkedin:
            platformCriteria = """
            LinkedIn Optimization Criteria:
            - First line must hook before the "see more" fold (roughly 140 chars)
            - Storytelling format: personal anecdote → lesson → takeaway
            - Use line breaks and spacing liberally (no walls of text)
            - Lists and numbered points increase readability
            - Professional but authentic tone (not corporate jargon)
            - End with a question or CTA to drive comments
            - Emojis can be used for bullet points or emphasis
            - 1300-2000 chars is the sweet spot for engagement
            """
        }

        return """
        You are a social media virality expert. Analyze the user's post and provide an optimized version with scoring.

        \(platformCriteria)

        Respond with ONLY valid JSON in this exact format (no markdown, no code fences):
        {
            "score": <0-100 overall virality score>,
            "hookScore": <0-10 opening hook strength>,
            "engagementScore": <0-10 engagement potential>,
            "clarityScore": <0-10 message clarity>,
            "formatScore": <0-10 platform-specific formatting>,
            "optimizedText": "<the rewritten, optimized version of the post>",
            "suggestions": [
                {
                    "category": "<category name>",
                    "text": "<actionable suggestion>",
                    "icon": "<SF Symbol name>",
                    "priority": "<high|medium|low>"
                }
            ]
        }

        Rules:
        - Provide exactly 3-5 suggestions
        - The optimized text must respect the platform's character limit (\(platform.charLimit) chars)
        - Keep the original message's intent but make it more viral
        - Be specific in suggestions, not generic
        - Use valid SF Symbol names for icons (e.g., bolt.fill, hand.thumbsup.fill, text.quote, megaphone.fill, sparkles)
        - Score honestly — don't inflate scores
        """
    }

    private static func buildUserMessage(text: String, platform: SocialPlatform) -> String {
        return """
        Optimize this \(platform.shortName) post for maximum virality:

        \(text)
        """
    }

    // MARK: - Response Parsing

    private static func parseResponse(_ response: String, originalText: String, platform: SocialPlatform) throws -> TextAnalysisResult {
        // Clean response: strip markdown code fences if present
        var cleaned = response.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("```json") {
            cleaned = String(cleaned.dropFirst(7))
        } else if cleaned.hasPrefix("```") {
            cleaned = String(cleaned.dropFirst(3))
        }
        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else {
            throw APIClient.APIError.decodingError("Failed to convert response to data")
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIClient.APIError.decodingError("Response is not valid JSON")
        }

        let score = json["score"] as? Int ?? 50
        let hookScore = json["hookScore"] as? Int ?? 5
        let engagementScore = json["engagementScore"] as? Int ?? 5
        let clarityScore = json["clarityScore"] as? Int ?? 5
        let formatScore = json["formatScore"] as? Int ?? 5
        let optimizedText = json["optimizedText"] as? String ?? originalText

        var suggestions: [TextSuggestion] = []
        if let suggestionsArray = json["suggestions"] as? [[String: Any]] {
            for item in suggestionsArray {
                let category = item["category"] as? String ?? "General"
                let text = item["text"] as? String ?? ""
                let icon = item["icon"] as? String ?? "lightbulb.fill"
                let priorityStr = item["priority"] as? String ?? "medium"
                let priority = TextSuggestion.SuggestionPriority(rawValue: priorityStr) ?? .medium

                guard !text.isEmpty else { continue }
                suggestions.append(TextSuggestion(
                    category: category,
                    text: text,
                    icon: icon,
                    priority: priority
                ))
            }
        }

        return TextAnalysisResult(
            id: UUID(),
            date: Date(),
            platform: platform,
            originalText: originalText,
            optimizedText: optimizedText,
            score: clamp(score, 0, 100),
            hookScore: clamp(hookScore, 0, 10),
            engagementScore: clamp(engagementScore, 0, 10),
            clarityScore: clamp(clarityScore, 0, 10),
            formatScore: clamp(formatScore, 0, 10),
            suggestions: suggestions
        )
    }

    private static func clamp(_ value: Int, _ min: Int, _ max: Int) -> Int {
        Swift.min(Swift.max(value, min), max)
    }
}
