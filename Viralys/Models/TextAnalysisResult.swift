import Foundation

// MARK: - Social Platform
/// Supported social platforms for text post optimization
enum SocialPlatform: String, Codable, CaseIterable {
    case twitter
    case linkedin

    var displayName: String {
        switch self {
        case .twitter: return "Twitter / X"
        case .linkedin: return "LinkedIn"
        }
    }

    var icon: String {
        switch self {
        case .twitter: return "bird"
        case .linkedin: return "briefcase.fill"
        }
    }

    var charLimit: Int {
        switch self {
        case .twitter: return 280
        case .linkedin: return 3000
        }
    }

    var shortName: String {
        switch self {
        case .twitter: return "Twitter"
        case .linkedin: return "LinkedIn"
        }
    }
}

// MARK: - Text Suggestion
/// Individual actionable suggestion from the analysis
struct TextSuggestion: Codable, Identifiable {
    let id: UUID
    let category: String
    let text: String
    let icon: String
    let priority: SuggestionPriority

    enum SuggestionPriority: String, Codable {
        case high
        case medium
        case low

        var label: String {
            switch self {
            case .high: return "High"
            case .medium: return "Medium"
            case .low: return "Low"
            }
        }

        var color: String {
            switch self {
            case .high: return "FF6B6B"
            case .medium: return "FFA726"
            case .low: return "00D68F"
            }
        }
    }

    init(id: UUID = UUID(), category: String, text: String, icon: String, priority: SuggestionPriority) {
        self.id = id
        self.category = category
        self.text = text
        self.icon = icon
        self.priority = priority
    }
}

// MARK: - Text Analysis Result
/// Stores the result of a text post virality analysis
struct TextAnalysisResult: Codable, Identifiable {
    let id: UUID
    let date: Date
    let platform: SocialPlatform
    let originalText: String
    let optimizedText: String
    let score: Int              // 0-100 overall virality score

    // Sub-scores (0-10 display scale)
    let hookScore: Int          // Opening hook strength
    let engagementScore: Int    // Engagement potential (replies, shares)
    let clarityScore: Int       // Message clarity and readability
    let formatScore: Int        // Platform-specific formatting

    let suggestions: [TextSuggestion]

    // MARK: - Display Helpers

    var hookDescription: String {
        switch hookScore {
        case 9...10: return "Irresistible opening — people will stop scrolling"
        case 7...8:  return "Strong hook that grabs attention"
        case 5...6:  return "Decent opener but could be more compelling"
        case 3...4:  return "Weak hook — most people will scroll past"
        default:     return "No hook — needs a strong opening line"
        }
    }

    var engagementDescription: String {
        switch engagementScore {
        case 9...10: return "Extremely shareable — high reply and repost potential"
        case 7...8:  return "Strong engagement potential — people will interact"
        case 5...6:  return "Moderate engagement — some replies expected"
        case 3...4:  return "Low engagement — unlikely to spark conversation"
        default:     return "Very low engagement — needs a clear call to action"
        }
    }

    var clarityDescription: String {
        switch clarityScore {
        case 9...10: return "Crystal clear message — instantly understood"
        case 7...8:  return "Clear and well-written"
        case 5...6:  return "Readable but could be tighter"
        case 3...4:  return "Unclear — readers may not get the point"
        default:     return "Confusing — needs complete rewrite for clarity"
        }
    }

    var formatDescription: String {
        switch platform {
        case .twitter:
            switch formatScore {
            case 9...10: return "Perfect Twitter format — concise and punchy"
            case 7...8:  return "Good format for Twitter engagement"
            case 5...6:  return "Acceptable but could use better structure"
            case 3...4:  return "Poor format — too long or no visual breaks"
            default:     return "Wrong format for Twitter entirely"
            }
        case .linkedin:
            switch formatScore {
            case 9...10: return "Perfect LinkedIn format — great use of hooks and spacing"
            case 7...8:  return "Good LinkedIn formatting with clear structure"
            case 5...6:  return "Needs better spacing or \"see more\" hook"
            case 3...4:  return "Wall of text — needs formatting badly"
            default:     return "Not formatted for LinkedIn at all"
            }
        }
    }

    var platformLabel: String { platform.displayName }

    var previewText: String {
        let limit = 80
        if originalText.count <= limit { return originalText }
        return String(originalText.prefix(limit)) + "..."
    }
}
