import Foundation

// MARK: - Analysis Result Model
/// Stores the result of a video/slideshow virality analysis
struct AnalysisResult: Codable, Identifiable {
    let id: UUID
    let date: Date
    let thumbnailData: Data?
    let score: Int
    let hookScore: Int       // 0-10 display scale (raw 0-40 / 4)
    let pacingScore: Int     // 0-10 display scale (raw 0-20 / 2)
    let lengthScore: Int     // 0-10 display scale (raw 0-25 / 2.5)
    let qualityScore: Int    // 0-10 display scale (raw 0-10)
    let duration: Double
    let resolution: String

    // Slideshow metadata (nil for regular videos)
    let isSlideshow: Bool
    let imageCount: Int?
    let durationPerSlide: Double?
    let transitionType: String?

    // MARK: - Custom Decoding (backward compatibility)
    private enum CodingKeys: String, CodingKey {
        case id, date, thumbnailData, score, hookScore, pacingScore
        case lengthScore, qualityScore, duration, resolution
        case isSlideshow, imageCount, durationPerSlide, transitionType
    }

    init(
        id: UUID, date: Date, thumbnailData: Data?, score: Int,
        hookScore: Int, pacingScore: Int, lengthScore: Int, qualityScore: Int,
        duration: Double, resolution: String,
        isSlideshow: Bool = false, imageCount: Int? = nil,
        durationPerSlide: Double? = nil, transitionType: String? = nil
    ) {
        self.id = id; self.date = date; self.thumbnailData = thumbnailData
        self.score = score; self.hookScore = hookScore; self.pacingScore = pacingScore
        self.lengthScore = lengthScore; self.qualityScore = qualityScore
        self.duration = duration; self.resolution = resolution
        self.isSlideshow = isSlideshow; self.imageCount = imageCount
        self.durationPerSlide = durationPerSlide; self.transitionType = transitionType
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        date = try c.decode(Date.self, forKey: .date)
        thumbnailData = try c.decodeIfPresent(Data.self, forKey: .thumbnailData)
        score = try c.decode(Int.self, forKey: .score)
        hookScore = try c.decode(Int.self, forKey: .hookScore)
        pacingScore = try c.decode(Int.self, forKey: .pacingScore)
        lengthScore = try c.decode(Int.self, forKey: .lengthScore)
        qualityScore = try c.decode(Int.self, forKey: .qualityScore)
        duration = try c.decode(Double.self, forKey: .duration)
        resolution = try c.decode(String.self, forKey: .resolution)
        isSlideshow = (try? c.decode(Bool.self, forKey: .isSlideshow)) ?? false
        imageCount = try? c.decode(Int.self, forKey: .imageCount)
        durationPerSlide = try? c.decode(Double.self, forKey: .durationPerSlide)
        transitionType = try? c.decode(String.self, forKey: .transitionType)
    }

    // MARK: - Display Helpers

    var hookDescription: String {
        switch hookScore {
        case 9...10: return "Powerful opening that grabs attention instantly"
        case 7...8:  return "Strong hook — most viewers will stay"
        case 5...6:  return "Decent hook but not attention-grabbing enough"
        case 3...4:  return "Weak hook — most viewers will scroll past"
        case 1...2:  return "Very weak hook — viewers will scroll immediately"
        default:     return "No hook at all — static opening will kill your reach"
        }
    }

    var pacingDescription: String {
        switch pacingScore {
        case 9...10: return "Extremely dynamic — TikTok-perfect pacing"
        case 7...8:  return "Good pacing that keeps viewers watching"
        case 5...6:  return "Moderate pacing — could be tighter"
        case 3...4:  return "Slow pacing — viewers will lose interest"
        case 1...2:  return "Very slow — almost no cuts or transitions"
        default:     return "Completely static — needs editing badly"
        }
    }

    var lengthDescription: String {
        if duration <= 15 {
            return lengthScore >= 8
                ? "Perfect length — high completion rate and rewatchability"
                : "Short but may need more substance"
        }
        switch lengthScore {
        case 9...10: return "Perfect length for maximum completion rate"
        case 7...8:  return "Good length — most viewers will finish watching"
        case 5...6:  return "Acceptable length but completion rate will drop"
        case 3...4:  return "Too long — completion rate will be very low"
        case 1...2:  return "Way too long — TikTok penalizes low completion"
        default:     return "Extremely long — almost no one will watch to the end"
        }
    }

    var qualityDescription: String {
        switch qualityScore {
        case 9...10: return "Excellent — HD vertical with stable footage"
        case 7...8:  return "Good quality with proper TikTok format"
        case 5...6:  return "Acceptable quality — some issues with format or stability"
        case 3...4:  return "Below average — wrong format or low resolution"
        case 1...2:  return "Poor quality — hurting your reach significantly"
        default:     return "Very poor quality — upgrade your recording setup"
        }
    }

    var durationDisplay: String { duration.durationDisplay }

    // MARK: - Improvement Suggestions

    var hookSuggestions: [String] {
        guard hookScore < 7 else { return [] }
        var tips = [String]()
        if hookScore <= 2 {
            tips.append("Start with the END RESULT — show the 'after' first")
            tips.append("Add bold text in the first frame: 'Wait for it...'")
            tips.append("Use a shocking visual or fast movement immediately")
            tips.append("This is your #1 priority — nothing else matters if people scroll past")
        } else if hookScore <= 4 {
            tips.append("Add a bold text overlay in the first frame")
            tips.append("Start with the most dramatic moment")
            tips.append("Try a trending transition that starts in frame 1")
        } else {
            tips.append("Make the first second more visually striking")
            tips.append("Use a question or surprising statement to open")
        }
        if isSlideshow { tips.append("Lead with your most eye-catching photo") }
        return tips
    }

    var pacingSuggestions: [String] {
        guard pacingScore < 7 else { return [] }
        var tips = [String]()
        if pacingScore <= 2 {
            tips.append("Add more cuts — aim for 1 cut every 2-3 seconds")
            tips.append("Speed up the video 1.2-1.5x")
            tips.append("Show multiple angles of the same action")
            tips.append("Add text overlays that change every 3-4 seconds")
        } else if pacingScore <= 4 {
            tips.append("Add more cuts and transitions between scenes")
            tips.append("Use jump cuts to remove dead space")
            tips.append("Show multiple angles of the same moment")
        } else {
            tips.append("Tighten your edits — remove any pauses or dead time")
            tips.append("Add visual variety to maintain interest")
        }
        if isSlideshow { tips.append("Use shorter slide durations (2s per slide)") }
        return tips
    }

    var lengthSuggestions: [String] {
        guard lengthScore < 7 else { return [] }
        var tips = [String]()
        if duration > 60 {
            tips.append("TRIM to 30 seconds or less — current length kills completion rate")
            tips.append("Cut out any 'fluff' or slow moments")
            tips.append("Save longer content for YouTube Shorts (different algorithm)")
        } else if duration > 45 {
            tips.append("Trim to 30 seconds or less for maximum retention")
            tips.append("Cut out the slow middle section")
        } else if duration > 30 {
            tips.append("Cut to under 30 seconds — every second counts")
            tips.append("Get to the point faster")
        } else if duration < 5 {
            tips.append("Add a bit more content — at least 7 seconds")
        }
        tips.append("Make every single second earn its place")
        return tips
    }

    var qualitySuggestions: [String] {
        guard qualityScore < 7 else { return [] }
        var tips = [String]()
        if qualityScore <= 3 {
            tips.append("Film in 1080p or higher resolution")
            tips.append("Ensure good lighting — natural light works best")
        }
        if !resolution.contains("1920") && !resolution.contains("1080") {
            tips.append("Crop to vertical 9:16 format for TikTok")
        }
        if qualityScore <= 5 {
            tips.append("Keep the camera steady or use stabilization")
        }
        return tips
    }

    /// Top 3 weakest areas with suggestions
    var topIssues: [(category: String, icon: String, score: Int, suggestions: [String])] {
        let all = [
            (category: "Hook Strength", icon: "bolt.fill", score: hookScore, suggestions: hookSuggestions),
            (category: "Pacing", icon: "film", score: pacingScore, suggestions: pacingSuggestions),
            (category: "Video Length", icon: "clock.fill", score: lengthScore, suggestions: lengthSuggestions),
            (category: "Production Quality", icon: "sparkles", score: qualityScore, suggestions: qualitySuggestions)
        ]
        return all
            .filter { !$0.suggestions.isEmpty }
            .sorted { $0.score < $1.score }
            .prefix(3)
            .map { $0 }
    }
}
