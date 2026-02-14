import AVFoundation
import CoreImage
import UIKit

// MARK: - Video Analyzer
/// Analyzes video properties to compute a virality score (0-100) based on real TikTok algorithm factors.
/// TikTok priorities: Completion Rate > Engagement > Watch Time > Likes
///
/// Scoring breakdown:
///   Hook Quality:  40 points (MOST CRITICAL — first 3 seconds)
///   Video Length:   25 points (completion rate potential)
///   Pacing:         20 points (engagement retention)
///   Quality:        10 points (production value)
///   Technical:       5 points (optimization)
///
/// Penalty system subtracts from total. Hook cap at 45 if hook < 15/40.
final class VideoAnalyzer {

    // MARK: - Analysis Entry Point
    static func analyze(
        url: URL,
        slideshowConfig: SlideshowConfig? = nil,
        completion: @escaping (AnalysisResult?) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: url)
            let tracks = asset.tracks(withMediaType: .video)
            guard let videoTrack = tracks.first else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            let duration = CMTimeGetSeconds(asset.duration)
            let resolution = videoTrack.naturalSize
            let frameRate = videoTrack.nominalFrameRate

            var fileSize: Int64 = 0
            if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
               let size = attrs[.size] as? Int64 {
                fileSize = size
            }

            // Extract frames at 0.5s intervals (up to 60 frames)
            let frames = extractFrames(asset: asset, duration: duration)

            // ━━━ FACTOR 1: Hook Quality (max 40) ━━━
            let hookVisual = calculateHookVisual(frames: frames)         // 0-15
            let hookContrast = calculateHookContrast(frames: frames)     // 0-10
            let hookMotion = calculateHookMotion(frames: frames)         // 0-10
            let hookTiming = calculateHookTiming(frames: frames)         // 0-5
            let hookTotal = hookVisual + hookContrast + hookMotion + hookTiming  // 0-40

            // ━━━ FACTOR 2: Video Length (max 25) ━━━
            let lengthBase = calculateLengthScore(duration: duration)    // 0-25
            let pacingRaw = calculatePacingScore(frames: frames, duration: duration) // 0-20

            // Retention prediction bonus/penalty
            var lengthScore = lengthBase
            if duration >= 7 && duration <= 30 && pacingRaw >= 12 {
                lengthScore = min(25, lengthScore + 3)  // Optimal length + good pacing
            }
            if duration > 45 && pacingRaw < 7 {
                lengthScore = max(0, lengthScore - 5)   // Long + slow = bad retention
            }

            // ━━━ FACTOR 3: Pacing / Engagement (max 20) ━━━
            let pacingTotal = pacingRaw  // Already includes engagement bonuses, capped at 20

            // ━━━ FACTOR 4: Production Quality (max 10) ━━━
            let qualityScore = calculateQualityScore(resolution: resolution, frames: frames)

            // ━━━ FACTOR 5: Technical (max 5) ━━━
            let technicalScore = calculateTechScore(fileSize: fileSize, duration: duration, frameRate: frameRate)

            // ━━━ STEP 1: Base score ━━━
            var base = hookTotal + lengthScore + pacingTotal + qualityScore + technicalScore

            // ━━━ STEP 2: Apply penalties ━━━
            let (fatal, major, minor) = calculatePenalties(
                frames: frames, resolution: resolution, duration: duration, hookTotal: hookTotal
            )
            base -= (fatal * 15)
            base -= (major * 8)
            base -= (minor * 3)

            // ━━━ Slideshow adjustments ━━━
            if let config = slideshowConfig {
                base += config.slideshowBonus
                base -= config.slideshowPenalty
            }

            // ━━━ STEP 3: Apply caps and floors ━━━
            if hookTotal < 15 {
                base = min(base, 45)  // Bad hook caps entire video at 45
            }
            if pacingTotal < 7 {
                base -= 10  // Extra penalty for slow pacing
            }
            if duration > 60 && pacingTotal < 10 {
                base -= 8   // Long + slow = double penalty
            }

            base = max(0, min(100, base))

            // ━━━ STEP 4: Small variance ━━━
            let variance = Int.random(in: -2...2)
            let finalScore = max(0, min(100, base + variance))

            // ━━━ Generate thumbnail ━━━
            let thumbnail = generateThumbnail(asset: asset)

            // ━━━ Convert to /10 display scores ━━━
            let hookDisplay = max(0, min(10, Int(round(Double(hookTotal) / 4.0))))
            let pacingDisplay = max(0, min(10, Int(round(Double(pacingTotal) / 2.0))))
            let lengthDisplay = max(0, min(10, Int(round(Double(lengthScore) / 2.5))))
            let qualityDisplay = max(0, min(10, qualityScore))

            let resString = "\(Int(resolution.width))x\(Int(resolution.height))"

            let result = AnalysisResult(
                id: UUID(),
                date: Date(),
                thumbnailData: thumbnail?.jpegData(compressionQuality: 0.6),
                score: finalScore,
                hookScore: hookDisplay,
                pacingScore: pacingDisplay,
                lengthScore: lengthDisplay,
                qualityScore: qualityDisplay,
                duration: duration,
                resolution: resString,
                isSlideshow: slideshowConfig != nil,
                imageCount: slideshowConfig?.imageCount,
                durationPerSlide: slideshowConfig?.durationPerSlide,
                transitionType: slideshowConfig?.transitionType.rawValue
            )

            DispatchQueue.main.async { completion(result) }
        }
    }

    // MARK: - Frame Extraction
    private static func extractFrames(asset: AVAsset, duration: Double) -> [CGImage] {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 320, height: 320)
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = CMTime(seconds: 0.1, preferredTimescale: 600)

        var frames: [CGImage] = []
        let interval = 0.5
        let sampleCount = min(Int(duration / interval), 60)

        for i in 0...sampleCount {
            let time = CMTime(seconds: Double(i) * interval, preferredTimescale: 600)
            if let image = try? generator.copyCGImage(at: time, actualTime: nil) {
                frames.append(image)
            }
        }
        return frames
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - FACTOR 1: HOOK QUALITY (40 POINTS TOTAL)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    // MARK: Visual Hook (0-15 points)
    // Measures pixel change in first 3 seconds (frames 0-6 at 0.5s intervals)
    private static func calculateHookVisual(frames: [CGImage]) -> Int {
        guard frames.count >= 2 else { return 0 }

        // First 3 seconds = frames at 0s, 0.5s, 1s, 1.5s, 2s, 2.5s, 3s = indices 0-6
        let hookFrames = Array(frames.prefix(min(7, frames.count)))

        var majorChanges = 0
        for i in 1..<hookFrames.count {
            let diff = pixelDifference(hookFrames[i - 1], hookFrames[i])
            if diff > 0.15 { majorChanges += 1 }  // >15% pixels different = significant
        }

        switch majorChanges {
        case 5...:  return 15  // Very dynamic: text appears, face closeup, action
        case 3...4: return 11  // Good movement/cuts
        case 2:     return 7   // Some action
        case 1:     return 4   // Minimal hook
        default:    return 0   // Static — instant scroll
        }
    }

    // MARK: Contrast / Attention-Grabbing (0-10 points)
    // Analyzes first frame brightness and contrast
    private static func calculateHookContrast(frames: [CGImage]) -> Int {
        guard let first = frames.first else { return 0 }

        let brightness = averageBrightness(first)
        let contrast = calculateContrast(first)

        // Very dark or very bright = hard to see = 0 points
        if brightness < 0.10 || brightness > 0.93 { return 0 }

        // High contrast subjects (bright vs dark areas)
        if contrast > 0.25 { return 10 }      // High contrast
        if contrast > 0.15 { return 6 }       // Moderate contrast
        if contrast > 0.08 { return 2 }       // Low contrast / washed out
        return 0
    }

    // MARK: Motion Intensity (0-10 points)
    // Detects overall motion in first 3 seconds via frame-to-frame differences
    private static func calculateHookMotion(frames: [CGImage]) -> Int {
        guard frames.count >= 3 else { return 0 }

        let hookFrames = Array(frames.prefix(min(7, frames.count)))

        // Sum up all frame-to-frame differences in the hook period
        var totalMotion: Double = 0
        var pairCount = 0
        for i in 1..<hookFrames.count {
            totalMotion += pixelDifference(hookFrames[i - 1], hookFrames[i])
            pairCount += 1
        }

        guard pairCount > 0 else { return 0 }
        let avgMotion = totalMotion / Double(pairCount)

        if avgMotion > 0.20 { return 10 }     // High motion (fast movement, camera moves)
        if avgMotion > 0.12 { return 6 }      // Moderate motion
        if avgMotion > 0.05 { return 3 }      // Slow / minimal motion
        return 0                               // Static (tripod, no movement)
    }

    // MARK: Hook Timing Bonus (0-5 points)
    // Rewards action happening within the first second
    private static func calculateHookTiming(frames: [CGImage]) -> Int {
        guard frames.count >= 4 else { return 0 }

        // Check if significant action happens within first 1 second (frames 0-2, at 0s/0.5s/1s)
        let firstSecondChanges: Double = {
            var total: Double = 0
            let limit = min(3, frames.count)
            for i in 1..<limit {
                total += pixelDifference(frames[i - 1], frames[i])
            }
            return total
        }()

        if firstSecondChanges > 0.25 { return 5 }  // Immediate action within 1 second

        // Check if action starts at 1-3 seconds (frames 2-6)
        if frames.count >= 5 {
            let midChanges: Double = {
                var total: Double = 0
                let start = min(2, frames.count - 1)
                let end = min(6, frames.count)
                for i in start..<end {
                    if i > 0 {
                        total += pixelDifference(frames[i - 1], frames[i])
                    }
                }
                return total
            }()
            if midChanges > 0.20 { return 2 }  // Action starts at 2-3 seconds
        }

        return 0  // Nothing happens until after 3 seconds
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - FACTOR 2: VIDEO LENGTH (25 POINTS)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private static func calculateLengthScore(duration: Double) -> Int {
        switch duration {
        case 7...15:  return 25  // BEST — highest completion rate, rewatchability
        case 16...21: return 22  // Excellent — still easy to complete
        case 22...30: return 18  // Good — sweet spot for most content
        case 31...40: return 13  // Acceptable — needs strong content to retain
        case 41...50: return 8   // Risky — completion drops significantly
        case 51...60: return 4   // Hard to keep attention
        case 61...90: return 2   // Very low completion rates
        default:
            if duration < 3 { return 2 }       // Too short to engage
            else if duration < 7 { return 12 } // Okay but less rewatchable
            else { return 0 }                   // 90+ seconds — almost never completed
        }
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - FACTOR 3: PACING / ENGAGEMENT RETENTION (20 POINTS)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private static func calculatePacingScore(frames: [CGImage], duration: Double) -> Int {
        guard frames.count >= 4, duration > 0 else { return 0 }

        // Count scene changes (cuts/transitions) throughout the video
        var sceneChanges = 0
        for i in 1..<frames.count {
            let diff = pixelDifference(frames[i - 1], frames[i])
            if diff > 0.20 { sceneChanges += 1 }  // Significant visual change = cut
        }

        // Calculate cuts per 10 seconds
        let cutsPer10 = (Double(sceneChanges) / max(1, duration)) * 10.0

        var score: Int
        switch cutsPer10 {
        case 6...:    score = 20  // Extremely dynamic — TikTok style
        case 4..<6:   score = 16  // Good pacing — professional
        case 3..<4:   score = 12  // Moderate — acceptable
        case 2..<3:   score = 7   // Slow — needs improvement
        case 1..<2:   score = 3   // Very slow — boring
        default:      score = 0   // Static — will lose viewers
        }

        // ENGAGEMENT BONUSES (up to +7, but total capped at 20)

        // Distinct segments: cuts distributed across beginning, middle, end
        if frames.count >= 10 && sceneChanges >= 3 {
            let third = frames.count / 3
            var seg1 = 0, seg2 = 0, seg3 = 0
            for i in 1..<frames.count {
                if pixelDifference(frames[i - 1], frames[i]) > 0.20 {
                    if i < third { seg1 += 1 }
                    else if i < third * 2 { seg2 += 1 }
                    else { seg3 += 1 }
                }
            }
            if seg1 > 0 && seg2 > 0 && seg3 > 0 {
                score += 3  // Has intro/body/conclusion structure
            }
        }

        // Multiple perspectives/angles: varied visual content
        if sceneChanges >= 4 {
            // Check if cuts produce genuinely different content (not just movement)
            var distinctScenes = 0
            for i in 1..<frames.count {
                if pixelDifference(frames[i - 1], frames[i]) > 0.35 {
                    distinctScenes += 1  // Major visual shift = different angle/scene
                }
            }
            if distinctScenes >= 3 { score += 2 }
        }

        // Text overlays / frequent visual changes that keep attention
        if frames.count >= 6 {
            var smallChanges = 0
            for i in 1..<frames.count {
                let diff = pixelDifference(frames[i - 1], frames[i])
                if diff > 0.08 && diff < 0.20 { smallChanges += 1 }
            }
            let changeRate = Double(smallChanges) / Double(frames.count - 1)
            if changeRate > 0.5 { score += 2 }  // Lots of subtle changes = text/overlays
        }

        return min(20, max(0, score))
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - FACTOR 4: PRODUCTION QUALITY (10 POINTS)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private static func calculateQualityScore(resolution: CGSize, frames: [CGImage]) -> Int {
        let maxDim = max(resolution.width, resolution.height)
        let minDim = min(resolution.width, resolution.height)

        // Resolution (0-5)
        var resScore: Int
        if maxDim >= 1080 { resScore = 5 }
        else if maxDim >= 720 { resScore = 3 }
        else { resScore = 1 }

        // Aspect ratio (0-3)
        var aspectScore: Int = 0
        let aspect = minDim / maxDim
        if aspect > 0.54 && aspect < 0.58 {
            aspectScore = 3  // Perfect 9:16 vertical
        } else if abs(aspect - 0.5625) < 0.03 {
            aspectScore = 2  // Close to 9:16 (within ~5%)
        }
        // Wrong ratio (16:9, 1:1, with black bars) = 0

        // Stability (0-2) — detect shakiness via micro-movements
        var stabilityScore: Int = 2  // Assume stable
        if frames.count >= 6 {
            var microShakes = 0
            for i in 1..<min(frames.count, 12) {
                let diff = pixelDifference(frames[i - 1], frames[i])
                if diff > 0.03 && diff < 0.08 { microShakes += 1 }
            }
            let sampledCount = min(frames.count - 1, 11)
            let shakeRatio = Double(microShakes) / Double(max(1, sampledCount))
            if shakeRatio > 0.7 { stabilityScore = 0 }       // Very shaky
            else if shakeRatio > 0.4 { stabilityScore = 1 }  // Moderate shake
        }

        return min(10, resScore + aspectScore + stabilityScore)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - FACTOR 5: TECHNICAL OPTIMIZATION (5 POINTS)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private static func calculateTechScore(fileSize: Int64, duration: Double, frameRate: Float) -> Int {
        var score = 0

        // File compression: 0.3-0.7 MB/sec is optimal (0-3)
        let mbPerSec = Double(fileSize) / 1_000_000.0 / max(1, duration)
        if mbPerSec >= 0.3 && mbPerSec <= 0.7 { score += 3 }
        else if mbPerSec >= 0.15 && mbPerSec <= 1.2 { score += 1 }

        // Frame rate: 30fps or 60fps (0-2)
        if frameRate >= 59.0 && frameRate <= 61.0 { score += 2 }
        else if frameRate >= 29.0 && frameRate <= 31.0 { score += 2 }
        else if frameRate >= 23.0 && frameRate <= 25.0 { score += 1 }

        return min(5, score)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - PENALTY SYSTEM
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private static func calculatePenalties(
        frames: [CGImage],
        resolution: CGSize,
        duration: Double,
        hookTotal: Int
    ) -> (fatal: Int, major: Int, minor: Int) {
        var fatal = 0
        var major = 0
        var minor = 0

        // ━━━ FATAL FLAWS (-15 each) ━━━

        // Horizontal video with black bars (not TikTok native)
        if resolution.width > resolution.height * 1.3 {
            fatal += 1
        }

        // First 3 seconds completely static (no hook at all)
        if frames.count >= 4 {
            var hookStatic = true
            for i in 1..<min(7, frames.count) {
                if pixelDifference(frames[i - 1], frames[i]) > 0.05 {
                    hookStatic = false
                    break
                }
            }
            if hookStatic { fatal += 1 }
        }

        // Video > 90 seconds
        if duration > 90 { fatal += 1 }

        // ━━━ MAJOR ISSUES (-8 each) ━━━

        // Very dark / poorly lit
        if frames.count >= 3 {
            let avgBrightness = frames.prefix(5).map { averageBrightness($0) }
                .reduce(0, +) / Double(min(5, frames.count))
            if avgBrightness < 0.12 { major += 1 }
        }

        // Extremely shaky footage
        if frames.count >= 8 {
            var heavyShakes = 0
            for i in 1..<min(frames.count, 16) {
                let diff = pixelDifference(frames[i - 1], frames[i])
                if diff > 0.04 && diff < 0.09 { heavyShakes += 1 }
            }
            let sampledCount = min(frames.count - 1, 15)
            if Double(heavyShakes) / Double(sampledCount) > 0.8 { major += 1 }
        }

        // Wrong aspect ratio (16:9 horizontal or 1:1 square)
        let aspect = min(resolution.width, resolution.height) / max(resolution.width, resolution.height)
        if aspect > 0.90 {
            major += 1  // Square (1:1)
        } else if aspect > 0.70 && resolution.width > resolution.height {
            major += 1  // 16:9 landscape — wrong for TikTok
        }

        // Zero scene changes (completely static video)
        if frames.count >= 6 {
            var anyCuts = false
            for i in 1..<frames.count {
                if pixelDifference(frames[i - 1], frames[i]) > 0.15 {
                    anyCuts = true
                    break
                }
            }
            if !anyCuts { major += 1 }
        }

        // ━━━ MINOR ISSUES (-3 each) ━━━

        // Low resolution (480p or lower)
        let maxDim = max(resolution.width, resolution.height)
        if maxDim < 480 { minor += 1 }

        // Poor compression (huge file)
        // (Handled elsewhere via tech score, but extreme cases get penalized)

        // Slow hook (nothing meaningful happens until 5+ seconds)
        if frames.count >= 11 {
            var earlyAction = false
            for i in 1..<min(10, frames.count) {  // First 5 seconds (10 frames at 0.5s)
                if pixelDifference(frames[i - 1], frames[i]) > 0.15 {
                    earlyAction = true
                    break
                }
            }
            if !earlyAction { minor += 1 }
        }

        return (fatal, major, minor)
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // MARK: - Image Analysis Helpers
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    private static func pixelDifference(_ a: CGImage, _ b: CGImage) -> Double {
        let size = CGSize(width: 32, height: 32)
        guard let ctxA = createContext(size: size),
              let ctxB = createContext(size: size) else { return 0 }

        let rect = CGRect(origin: .zero, size: size)
        ctxA.draw(a, in: rect)
        ctxB.draw(b, in: rect)

        guard let dataA = ctxA.data, let dataB = ctxB.data else { return 0 }

        let pixelCount = Int(size.width * size.height)
        let bytesPerPixel = 4
        var totalDiff: Double = 0
        let bufferA = dataA.assumingMemoryBound(to: UInt8.self)
        let bufferB = dataB.assumingMemoryBound(to: UInt8.self)

        for i in 0..<(pixelCount * bytesPerPixel) {
            totalDiff += abs(Double(bufferA[i]) - Double(bufferB[i]))
        }
        return totalDiff / Double(pixelCount * bytesPerPixel * 255)
    }

    private static func averageBrightness(_ image: CGImage) -> Double {
        let size = CGSize(width: 16, height: 16)
        guard let ctx = createContext(size: size) else { return 0.5 }
        ctx.draw(image, in: CGRect(origin: .zero, size: size))
        guard let data = ctx.data else { return 0.5 }

        let count = Int(size.width * size.height)
        let buf = data.assumingMemoryBound(to: UInt8.self)
        var total: Double = 0
        for i in 0..<count {
            let o = i * 4
            total += (Double(buf[o]) * 0.299 + Double(buf[o+1]) * 0.587 + Double(buf[o+2]) * 0.114) / 255.0
        }
        return total / Double(count)
    }

    /// Calculates contrast as standard deviation of pixel brightness across the image
    private static func calculateContrast(_ image: CGImage) -> Double {
        let size = CGSize(width: 16, height: 16)
        guard let ctx = createContext(size: size) else { return 0 }
        ctx.draw(image, in: CGRect(origin: .zero, size: size))
        guard let data = ctx.data else { return 0 }

        let count = Int(size.width * size.height)
        let buf = data.assumingMemoryBound(to: UInt8.self)

        var values: [Double] = []
        values.reserveCapacity(count)
        for i in 0..<count {
            let o = i * 4
            let lum = (Double(buf[o]) * 0.299 + Double(buf[o+1]) * 0.587 + Double(buf[o+2]) * 0.114) / 255.0
            values.append(lum)
        }

        let mean = values.reduce(0, +) / Double(count)
        let variance = values.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(count)
        return variance.squareRoot()  // Standard deviation of brightness
    }

    private static func createContext(size: CGSize) -> CGContext? {
        CGContext(
            data: nil, width: Int(size.width), height: Int(size.height),
            bitsPerComponent: 8, bytesPerRow: Int(size.width) * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    }

    private static func generateThumbnail(asset: AVAsset) -> UIImage? {
        let gen = AVAssetImageGenerator(asset: asset)
        gen.appliesPreferredTrackTransform = true
        gen.maximumSize = CGSize(width: 400, height: 400)
        guard let cg = try? gen.copyCGImage(at: CMTime(seconds: 0.5, preferredTimescale: 600), actualTime: nil)
        else { return nil }
        return UIImage(cgImage: cg)
    }
}
