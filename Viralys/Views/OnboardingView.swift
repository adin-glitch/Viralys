import SwiftUI

// MARK: - Onboarding View
/// First-launch horizontal paging onboarding experience
struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var appeared = false

    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            icon: "video.badge.waveform",
            sparkleIcon: "sparkles",
            title: "Predict Virality",
            subtitle: "Upload your TikTok and get an instant AI-powered virality score"
        ),
        OnboardingSlide(
            icon: "magnifyingglass",
            sparkleIcon: "waveform.path.ecg",
            title: "Deep Insights",
            subtitle: "Understand hook strength, pacing, and what makes videos go viral"
        ),
        OnboardingSlide(
            icon: "trophy.fill",
            sparkleIcon: "star.fill",
            title: "Compare & Improve",
            subtitle: "Match your video against viral content and optimize for success"
        )
    ]

    var body: some View {
        ZStack {
            DS.Colors.background.ignoresSafeArea()

            VStack {
                // Skip button (shown on first 2 slides)
                HStack {
                    Spacer()
                    if currentPage < slides.count - 1 {
                        Button("Skip") {
                            HapticManager.selection()
                            completeOnboarding()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DS.Colors.textSecondary)
                        .padding(.trailing, DS.Spacing.lg)
                    }
                }
                .frame(height: 44)
                .padding(.top, DS.Spacing.sm)

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(slides.indices, id: \.self) { index in
                        slideView(slides[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(DS.Anim.spring, value: currentPage)

                // Page dots
                HStack(spacing: DS.Spacing.sm) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? DS.Colors.accent : DS.Colors.textSecondary.opacity(0.3))
                            .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                            .animation(DS.Anim.quick, value: currentPage)
                    }
                }
                .padding(.bottom, DS.Spacing.lg)

                // Bottom button
                if currentPage == slides.count - 1 {
                    GradientButton("Get Started", icon: "arrow.right") {
                        completeOnboarding()
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    GradientButton("Next", icon: "arrow.right") {
                        withAnimation(DS.Anim.spring) {
                            currentPage += 1
                        }
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                }

                Spacer().frame(height: DS.Spacing.xxl)
            }
        }
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(DS.Anim.spring) {
                appeared = true
            }
        }
    }

    private func slideView(_ slide: OnboardingSlide) -> some View {
        VStack(spacing: DS.Spacing.xl) {
            Spacer()

            // Animated icon area
            ZStack {
                Circle()
                    .fill(DS.Colors.primaryGradient)
                    .opacity(0.15)
                    .frame(width: 180, height: 180)

                Circle()
                    .fill(DS.Colors.primaryGradient)
                    .opacity(0.08)
                    .frame(width: 240, height: 240)

                Image(systemName: slide.icon)
                    .font(.system(size: 64))
                    .foregroundStyle(DS.Colors.primaryGradient)

                // Decorative sparkles
                AnimatedSparkle(delay: 0)
                    .offset(x: 60, y: -50)
                AnimatedSparkle(delay: 0.3)
                    .offset(x: -50, y: -60)
                AnimatedSparkle(delay: 0.6)
                    .offset(x: 70, y: 40)
            }
            .frame(height: 260)

            // Text
            VStack(spacing: DS.Spacing.md) {
                Text(slide.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(DS.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(slide.subtitle)
                    .font(.system(size: 17))
                    .foregroundColor(DS.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DS.Spacing.xl)
            }

            Spacer()
            Spacer()
        }
    }

    private func completeOnboarding() {
        withAnimation(DS.Anim.spring) {
            appState.hasSeenOnboarding = true
        }
    }
}

// MARK: - Onboarding Slide Model
struct OnboardingSlide {
    let icon: String
    let sparkleIcon: String
    let title: String
    let subtitle: String
}
