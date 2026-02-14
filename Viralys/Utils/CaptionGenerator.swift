import Foundation

// MARK: - Caption Generator
/// Generates context-aware TikTok caption suggestions based on score and content type
enum CaptionGenerator {

    static func generate(score: Int, isSlideshow: Bool, imageCount: Int?) -> [String] {
        if isSlideshow {
            return slideshowCaptions(score: score, imageCount: imageCount ?? 0)
        } else {
            return videoCaptions(score: score)
        }
    }

    // MARK: - Video Captions

    private static func videoCaptions(score: Int) -> [String] {
        switch score {
        case 81...:
            return [
                "This is going to blow up",
                "Drop a comment if you want part 2",
                "Why did this only take me 10 minutes to make?",
                "I wasn't supposed to post this but here we go",
                "Save this before it goes viral"
            ]
        case 66...80:
            return [
                "Really proud of this one, what do you think?",
                "Spent way too long on this lol",
                "This might be my best one yet",
                "Rate this 1-10 in the comments",
                "Share if this hits different"
            ]
        case 51...65:
            return [
                "Trying something new, what do you think?",
                "Learning as I go - any tips?",
                "Rate this 1-10",
                "Still experimenting with my style",
                "Feedback welcome! Drop a comment"
            ]
        case 31...50:
            return [
                "First attempt - be nice!",
                "Still figuring this out, any advice?",
                "Practice makes perfect, right?",
                "Work in progress - thoughts?",
                "Tell me what I should change"
            ]
        default:
            return [
                "Day 1 of learning to edit",
                "We all start somewhere!",
                "Any editing tips? I'm learning",
                "Roast my video in the comments",
                "Help me make this better - what's missing?"
            ]
        }
    }

    // MARK: - Slideshow Captions

    private static func slideshowCaptions(score: Int, imageCount: Int) -> [String] {
        var captions = [String]()

        // Generic slideshow captions
        captions.append("Wait for slide \(imageCount) \u{1F631}")
        captions.append("Which one is your favorite? (1-\(imageCount))")
        captions.append("Swipe for the transformation \u{27A1}\u{FE0F}")

        // Score-adapted
        if score >= 70 {
            captions.append("This slideshow is everything \u{2728}")
            captions.append("Save this for later!")
        } else if score >= 50 {
            captions.append("Did you catch slide \(max(2, imageCount / 2))? \u{1F440}")
            captions.append("Rate my photos 1-10")
        } else {
            captions.append("Trying out the slideshow trend")
            captions.append("Which photo should I have started with?")
        }

        // Hook ideas
        captions.append("Start with your most eye-catching photo")

        return captions
    }

    // MARK: - Hook Ideas (always shown)

    static func hookIdeas(isSlideshow: Bool) -> [String] {
        if isSlideshow {
            return [
                "Lead with your most striking photo",
                "Number your slides (1/\u{2026}, 2/\u{2026}) for engagement",
                "Add text overlay on the first image",
                "Use before/after as first and last slides",
                "Make the last slide a call-to-action"
            ]
        } else {
            return [
                "Start with the result, then show the process",
                "Open with a bold question or statement",
                "Use text on screen in the first second",
                "Begin with the most dramatic moment",
                "Add a pattern interrupt in the first 2 seconds"
            ]
        }
    }
}
