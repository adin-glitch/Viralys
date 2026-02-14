import SwiftUI

// MARK: - Splash Screen
/// Animated launch screen with gradient background and logo
struct SplashScreen: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var gradientStart = UnitPoint.topLeading
    @State private var gradientEnd = UnitPoint.bottomTrailing

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [DS.Colors.primaryPurple, DS.Colors.primaryBlue, DS.Colors.primaryPurple],
                startPoint: gradientStart,
                endPoint: gradientEnd
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    gradientStart = .bottomTrailing
                    gradientEnd = .topLeading
                }
            }

            VStack(spacing: DS.Spacing.lg) {
                Spacer()

                // Logo
                VStack(spacing: DS.Spacing.md) {
                    Image(systemName: "waveform.and.magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(.white)

                    Text("Viralys")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // Tagline with stagger
                VStack(spacing: DS.Spacing.sm) {
                    Text("Predict. Optimize. Go Viral.")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                .opacity(taglineOpacity)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(DS.Anim.spring.delay(0.2)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(DS.Anim.spring.delay(0.6)) {
                taglineOpacity = 1.0
            }
        }
    }
}
