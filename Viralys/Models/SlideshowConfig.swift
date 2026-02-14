import Foundation

// MARK: - Slideshow Configuration
/// Settings for generating a slideshow video from images
struct SlideshowConfig: Codable {
    var durationPerSlide: Double = 2.0
    var transitionType: TransitionType = .fade
    var imageCount: Int

    enum TransitionType: String, CaseIterable, Codable {
        case none = "None"
        case fade = "Fade"
        case slide = "Slide"
        case zoom = "Zoom"

        var icon: String {
            switch self {
            case .none:  return "square.split.2x1"
            case .fade:  return "circle.lefthalf.filled"
            case .slide: return "arrow.right.square"
            case .zoom:  return "arrow.up.left.and.arrow.down.right"
            }
        }
    }

    var totalDuration: Double {
        Double(imageCount) * durationPerSlide
    }

    /// Slideshow-specific scoring adjustments
    var slideshowBonus: Int {
        var bonus = 0
        // Image variety bonus
        if imageCount >= 5 { bonus += 5 }
        else if imageCount >= 4 { bonus += 3 }
        // Good pacing bonus
        if durationPerSlide >= 2.0 && durationPerSlide <= 3.0 { bonus += 3 }
        // Transition bonus
        if transitionType != .none { bonus += 2 }
        return bonus
    }

    /// Slideshow-specific penalties
    var slideshowPenalty: Int {
        var penalty = 0
        // Too fast
        if durationPerSlide < 1.0 { penalty += 5 }
        // Too slow
        if durationPerSlide > 4.0 { penalty += 5 }
        // Too few images
        if imageCount <= 3 { penalty += 3 }
        return penalty
    }
}
