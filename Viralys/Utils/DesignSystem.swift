import SwiftUI

// MARK: - Design System
/// Centralized design tokens for the Viralys app
enum DS {

    // MARK: - Colors
    enum Colors {
        static let primaryPurple = Color(hex: "6C5CE7")
        static let primaryBlue = Color(hex: "0984E3")
        static let background = Color.black
        static let card = Color(hex: "1A1A1A")
        static let cardElevated = Color(hex: "252525")
        static let textPrimary = Color.white
        static let textSecondary = Color(hex: "A0A0A0")
        static let success = Color(hex: "00D68F")
        static let successBright = Color(hex: "00FF88")
        static let warning = Color(hex: "FFA726")
        static let yellow = Color(hex: "FFD93D")
        static let error = Color(hex: "FF6B6B")
        static let accent = Color(hex: "00FFF0")

        // Gradients
        static let primaryGradient = LinearGradient(
            colors: [primaryPurple, primaryBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let successGradient = LinearGradient(
            colors: [Color(hex: "00D68F"), Color(hex: "00B894")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let warningGradient = LinearGradient(
            colors: [Color(hex: "FFA726"), Color(hex: "FDCB6E")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let errorGradient = LinearGradient(
            colors: [Color(hex: "FF6B6B"), Color(hex: "E17055")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let yellowGradient = LinearGradient(
            colors: [Color(hex: "FFD93D"), Color(hex: "FFA726")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let neonGradient = LinearGradient(
            colors: [Color(hex: "00FFF0"), Color(hex: "00D68F")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // MARK: - 7-Tier Score System (TikTok Algorithm Based)

        static func scoreGradient(for score: Int) -> LinearGradient {
            switch score {
            case 96...100: return LinearGradient(colors: [Color(hex: "FFD700"), Color(hex: "FF8C00")], startPoint: .topLeading, endPoint: .bottomTrailing) // Gold
            case 86...95:  return neonGradient
            case 71...85:  return successGradient
            case 56...70:  return LinearGradient(colors: [Color(hex: "6BCB77"), Color(hex: "00B894")], startPoint: .topLeading, endPoint: .bottomTrailing)
            case 41...55:  return yellowGradient
            case 26...40:  return warningGradient
            default:       return errorGradient
            }
        }

        static func scoreColor(for score: Int) -> Color {
            switch score {
            case 96...100: return Color(hex: "FFD700")  // Gold
            case 86...95:  return accent                 // Neon green
            case 71...85:  return success                // Bright green
            case 56...70:  return Color(hex: "6BCB77")   // Light green
            case 41...55:  return yellow                 // Yellow
            case 26...40:  return warning                // Orange
            default:       return error                  // Red
            }
        }

        static func scoreText(for score: Int) -> String {
            switch score {
            case 96...100: return "Extremely High Viral Potential"
            case 86...95:  return "High Viral Potential"
            case 71...85:  return "Good Viral Potential"
            case 56...70:  return "Moderate Viral Potential"
            case 41...55:  return "Below Average Potential"
            case 26...40:  return "Low Viral Potential"
            default:       return "Very Low Viral Potential"
            }
        }

        static func scoreSubtext(for score: Int) -> String {
            switch score {
            case 96...100: return "This has VIRAL written all over it! Post ASAP!"
            case 86...95:  return "Excellent video! Very likely to get high engagement."
            case 71...85:  return "Strong video! Could perform well with right timing/hashtags."
            case 56...70:  return "Decent video with room for optimization."
            case 41...55:  return "Has potential but needs improvements to stand out."
            case 26...40:  return "Needs significant work before posting."
            default:       return "This video is unlikely to perform well. Major improvements needed."
            }
        }
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }

    // MARK: - Animation
    enum Anim {
        static let spring = Animation.spring(response: 0.6, dampingFraction: 0.8)
        static let quick = Animation.spring(response: 0.3, dampingFraction: 0.8)
        static let slow = Animation.spring(response: 0.8, dampingFraction: 0.7)
    }

    // MARK: - Layout
    enum Layout {
        static let headerHeight: CGFloat = 200
        static let uploadCardHeight: CGFloat = 200
        static let scoreRingSize: CGFloat = 200
        static let thumbnailSize: CGFloat = 80
        static let breakdownCardHeight: CGFloat = 80
    }
}
