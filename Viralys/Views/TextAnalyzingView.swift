import SwiftUI

// MARK: - Text Analyzing View
/// Loading screen while Claude API processes the text post
struct TextAnalyzingView: View {
    let platform: SocialPlatform
    let onCancel: () -> Void

    @State private var rotation: Double = 0
    @State private var statusIndex = 0
    @State private var dotCount = 0
    @State private var pulseScale: CGFloat = 1.0

    private var statusMessages: [String] {
        switch platform {
        case .twitter:
            return [
                "Analyzing hook strength",
                "Checking engagement potential",
                "Evaluating brevity & punch",
                "Optimizing for virality",
                "Crafting your optimized post"
            ]
        case .linkedin:
            return [
                "Analyzing opening hook",
                "Checking storytelling structure",
                "Evaluating formatting & spacing",
                "Optimizing for engagement",
                "Crafting your optimized post"
            ]
        }
    }

    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    private let statusTimer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
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
                    Circle()
                        .fill(DS.Colors.primaryPurple.opacity(0.1))
                        .frame(width: 160, height: 160)
                        .scaleEffect(pulseScale)

                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            DS.Colors.primaryGradient,
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(rotation))

                    Image(systemName: "text.magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundStyle(DS.Colors.primaryGradient)
                }

                // Status text
                VStack(spacing: DS.Spacing.sm) {
                    Text("Optimizing your \(platform.shortName) post")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(DS.Colors.textPrimary)

                    Text(statusMessages[statusIndex] + String(repeating: ".", count: dotCount))
                        .font(.system(size: 15))
                        .foregroundColor(DS.Colors.textSecondary)
                        .animation(.none, value: dotCount)
                        .id("status-\(statusIndex)-\(dotCount)")
                }

                Spacer()

                // Cancel button
                Button {
                    onCancel()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(DS.Colors.textSecondary)
                }
                .padding(.bottom, DS.Spacing.xxl)
            }
        }
        .onAppear {
            startAnimations()
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

    private func startAnimations() {
        withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.15
        }
    }
}
