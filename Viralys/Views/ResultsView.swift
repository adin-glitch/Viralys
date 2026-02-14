import SwiftUI

// MARK: - Results View
/// Displays the virality score with animated breakdown, feedback, benchmark, and captions
struct ResultsView: View {
    let result: AnalysisResult
    let onDismiss: (() -> Void)?

    @EnvironmentObject var appState: AppState
    @State private var appeared = false
    @State private var showConfetti = false
    @State private var showParticles = false
    @State private var showPaywall = false
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            DS.Colors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: DS.Spacing.lg) {
                    // Top bar (only in flow mode)
                    if onDismiss != nil {
                        topBar
                    }

                    // Score section
                    scoreSection
                        .padding(.top, DS.Spacing.md)

                    // Slideshow info badge
                    if result.isSlideshow {
                        slideshowBadge
                    }

                    // Breakdown section
                    breakdownSection

                    // Feedback cards for weak areas
                    if !result.topIssues.isEmpty {
                        feedbackSection
                    }

                    // Viral benchmark
                    BenchmarkView(result: result)
                        .padding(.horizontal, DS.Spacing.lg)

                    // Caption suggestions
                    captionSection

                    // Premium CTA
                    if !appState.isPremium {
                        premiumCTA
                    }

                    // Bottom actions
                    bottomActions

                    Spacer().frame(height: DS.Spacing.xxl)
                }
            }

            // Confetti overlay for high scores
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }

            // Particles on score reveal
            if showParticles {
                ParticleEffect(
                    color: DS.Colors.scoreColor(for: result.score),
                    count: 15
                )
                .frame(width: 250, height: 250)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(appState)
        }
        .onAppear {
            withAnimation(DS.Anim.spring.delay(0.2)) {
                appeared = true
            }
            if result.score > 85 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showConfetti = true
                    HapticManager.success()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showParticles = true
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button(action: {
                HapticManager.selection()
                onDismiss?()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(DS.Colors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(DS.Colors.card)
                    .clipShape(Circle())
            }
            Spacer()
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.top, DS.Spacing.sm)
    }

    // MARK: - Score Section
    private var scoreSection: some View {
        VStack(spacing: DS.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(DS.Colors.scoreColor(for: result.score).opacity(0.1))
                    .frame(width: 260, height: 260)
                    .blur(radius: 30)

                ScoreRing(score: result.score)
            }

            // Score tier label
            Text(DS.Colors.scoreText(for: result.score))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(DS.Colors.scoreColor(for: result.score))
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.xs)
                .background(DS.Colors.scoreColor(for: result.score).opacity(0.12))
                .cornerRadius(DS.Radius.sm)

            // Duration and resolution tags
            HStack(spacing: DS.Spacing.md) {
                tag(icon: "clock", text: result.durationDisplay)
                tag(icon: "arrow.up.left.and.arrow.down.right", text: result.resolution)
                if result.isSlideshow, let count = result.imageCount {
                    tag(icon: "photo.stack", text: "\(count) slides")
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
    }

    private func tag(icon: String, text: String) -> some View {
        HStack(spacing: DS.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundColor(DS.Colors.textSecondary)
        .padding(.horizontal, DS.Spacing.md)
        .padding(.vertical, DS.Spacing.sm)
        .background(DS.Colors.card)
        .cornerRadius(DS.Radius.xl)
    }

    // MARK: - Slideshow Badge
    private var slideshowBadge: some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: "photo.stack.fill")
                .font(.system(size: 14))
                .foregroundColor(DS.Colors.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text("Slideshow Analysis")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DS.Colors.textPrimary)

                HStack(spacing: DS.Spacing.md) {
                    if let dps = result.durationPerSlide {
                        Text(String(format: "%.1fs/slide", dps))
                            .font(.system(size: 12))
                            .foregroundColor(DS.Colors.textSecondary)
                    }
                    if let transition = result.transitionType {
                        Text(transition)
                            .font(.system(size: 12))
                            .foregroundColor(DS.Colors.textSecondary)
                    }
                }
            }

            Spacer()
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.accent.opacity(0.08))
        .cornerRadius(DS.Radius.md)
        .padding(.horizontal, DS.Spacing.lg)
    }

    // MARK: - Breakdown Section
    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Analysis Breakdown")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(DS.Colors.textPrimary)
                .padding(.horizontal, DS.Spacing.lg)

            VStack(spacing: DS.Spacing.md) {
                AnalysisCard(
                    icon: "bolt.fill",
                    title: "Hook Strength",
                    score: result.hookScore,
                    description: result.hookDescription,
                    index: 0
                )

                AnalysisCard(
                    icon: "film",
                    title: "Pacing",
                    score: result.pacingScore,
                    description: result.pacingDescription,
                    index: 1
                )

                AnalysisCard(
                    icon: "clock.fill",
                    title: "Video Length",
                    score: result.lengthScore,
                    description: result.lengthDescription,
                    index: 2
                )

                AnalysisCard(
                    icon: "sparkles",
                    title: "Production Quality",
                    score: result.qualityScore,
                    description: result.qualityDescription,
                    index: 3
                )
            }
            .padding(.horizontal, DS.Spacing.lg)
        }
    }

    // MARK: - Feedback Section
    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(DS.Colors.warning)
                Text("How to Improve")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(DS.Colors.textPrimary)
            }
            .padding(.horizontal, DS.Spacing.lg)

            ForEach(Array(result.topIssues.enumerated()), id: \.offset) { index, issue in
                FeedbackCard(
                    category: issue.category,
                    icon: issue.icon,
                    score: issue.score,
                    suggestions: issue.suggestions,
                    index: index
                )
            }
            .padding(.horizontal, DS.Spacing.lg)
        }
    }

    // MARK: - Caption Section
    private var captionSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            HStack {
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 16))
                    .foregroundColor(DS.Colors.accent)
                Text("Caption Ideas")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(DS.Colors.textPrimary)
            }
            .padding(.horizontal, DS.Spacing.lg)

            Text("Tap to copy")
                .font(.system(size: 12))
                .foregroundColor(DS.Colors.textSecondary)
                .padding(.horizontal, DS.Spacing.lg)

            let captions = CaptionGenerator.generate(
                score: result.score,
                isSlideshow: result.isSlideshow,
                imageCount: result.imageCount
            )

            ForEach(captions.prefix(4), id: \.self) { caption in
                CaptionCard(caption: caption)
            }
            .padding(.horizontal, DS.Spacing.lg)
        }
    }

    // MARK: - Premium CTA
    private var premiumCTA: some View {
        VStack(spacing: DS.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DS.Colors.primaryPurple.opacity(0.2))
                    .frame(width: 56, height: 56)
                Image(systemName: "lock.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(DS.Colors.primaryGradient)
            }

            Text("Want to Know WHY?")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(DS.Colors.textPrimary)

            Text("Compare with viral TikToks and get detailed AI feedback")
                .font(.system(size: 15))
                .foregroundColor(DS.Colors.textSecondary)
                .multilineTextAlignment(.center)

            GradientButton("Unlock Premium", icon: "crown.fill") {
                showPaywall = true
            }

            TextButton("See what you're missing \u{2192}") {
                showPaywall = true
            }
        }
        .padding(DS.Spacing.lg)
        .background(DS.Colors.card)
        .cornerRadius(DS.Radius.lg)
        .gradientBorder(lineWidth: 1.5)
        .padding(.horizontal, DS.Spacing.lg)
    }

    // MARK: - Bottom Actions
    private var bottomActions: some View {
        VStack(spacing: DS.Spacing.md) {
            if onDismiss != nil {
                GradientButton("Analyze Another Video", icon: "arrow.clockwise", style: .secondary) {
                    onDismiss?()
                }
            }

            TextButton("Share Results") {
                HapticManager.impact(.light)
                showShareSheet = true
            }
        }
        .padding(.horizontal, DS.Spacing.lg)
    }
}
