import SwiftUI

// MARK: - Analyzing View
/// Loading screen with animated progress during video analysis
struct AnalyzingView: View {
    let videoURL: URL
    var slideshowConfig: SlideshowConfig?
    let onComplete: (AnalysisResult?) -> Void

    @State private var rotation: Double = 0
    @State private var statusIndex = 0
    @State private var dotCount = 0
    @State private var pulseScale: CGFloat = 1.0

    private var statusMessages: [String] {
        if slideshowConfig != nil {
            return [
                "Evaluating slide composition",
                "Checking visual flow",
                "Analyzing transitions",
                "Scoring slideshow impact",
                "Preparing results"
            ]
        } else {
            return [
                "Checking hook strength",
                "Analyzing pacing",
                "Evaluating quality",
                "Calculating virality score",
                "Preparing results"
            ]
        }
    }

    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    private let statusTimer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Gradient background
            DS.Colors.primaryGradient
                .opacity(0.3)
                .ignoresSafeArea()

            DS.Colors.background
                .opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: DS.Spacing.xl) {
                Spacer()

                // Animated spinner
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(DS.Colors.primaryPurple.opacity(0.1))
                        .frame(width: 160, height: 160)
                        .scaleEffect(pulseScale)

                    // Spinning gradient ring
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            DS.Colors.primaryGradient,
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(rotation))

                    // Inner icon
                    Image(systemName: slideshowConfig != nil ? "photo.stack" : "waveform.and.magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundStyle(DS.Colors.primaryGradient)
                }

                // Status text
                VStack(spacing: DS.Spacing.sm) {
                    Text(slideshowConfig != nil ? "Analyzing your slideshow" : "Analyzing your video")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(DS.Colors.textPrimary)

                    Text(statusMessages[statusIndex] + String(repeating: ".", count: dotCount))
                        .font(.system(size: 15))
                        .foregroundColor(DS.Colors.textSecondary)
                        .animation(.none, value: dotCount)
                        .id("status-\(statusIndex)-\(dotCount)")
                }

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            startAnimations()
            startAnalysis()
        }
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 4
        }
        .onReceive(statusTimer) { _ in
            withAnimation(DS.Anim.quick) {
                statusIndex = (statusIndex + 1) % statusMessages.count
            }
        }
    }

    // MARK: - Animations
    private func startAnimations() {
        withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.15
        }
    }

    // MARK: - Analysis
    private func startAnalysis() {
        let startTime = Date()
        let minimumDuration: TimeInterval = 2.5

        VideoAnalyzer.analyze(url: videoURL, slideshowConfig: slideshowConfig) { result in
            let elapsed = Date().timeIntervalSince(startTime)
            let remaining = max(0, minimumDuration - elapsed)

            DispatchQueue.main.asyncAfter(deadline: .now() + remaining) {
                HapticManager.success()
                onComplete(result)
            }
        }
    }
}
